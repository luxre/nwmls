require 'nwmls/base'
require 'nwmls/acts_as_nwmls_listing'

class Nwmls::Listing
  include Nwmls::Base
  include Nwmls::ActsAsNwmlsListing

  TYPE_TO_CLASS_MAP = {
    "RESI" =>  'Nwmls::ResidentialListing',
    "COND" => 'Nwmls::CondominiumListing',
    "BUSO" => 'Nwmls::BusinessOpportunityListing',
    "COMI" => 'Nwmls::CommercialListing',
    "FARM" => 'Nwmls::FarmListing',
    "MANU" => 'Nwmls::ManufacturedHomeListing', 
    "MULT" => 'Nwmls::MultiFamilyListing',
    "RENT" => 'Nwmls::RentalListing',
    "VACL" => 'Nwmls::VacantLandListing',
  }

  CODED_ELEMENTS = %w(
    AFH
    AGR
    AMP
    ANC
    APR
    ARC
    AllowAVM
    BDC
    BON
    BREO
    BRM
    BUS
    CL
    COO
    DNO
    DRM
    DW1
    DW2
    DW3
    DW4
    DW5
    DW6
    EFR
    ELE
    ENT
    ENV
    EXA
    F17
    FAC
    FAM
    FG1
    FG2
    FG3
    FG4
    FG5
    FG6
    FMR
    FRN
    FUR
    GAS
    KES
    KEY
    KIT
    LNI
    LNM
    LOF
    LRM
    LTG
    MBD
    MFY
    NC
    NIA
    OTR
    PAD
    PAS
    POL
    PTO
    PTYP
    ProhibitBLOG
    REM
    RO1
    RO2
    RO3
    RO4
    RO5
    RO6
    RRM
    SDA
    SEP
    SFA
    SHOADR
    SIN
    SKS
    SML
    SNR
    SPA
    ST
    STO
    STY
    TOF
    UBG
    UCS
    UTR
    WD1
    WD2
    WD3
    WD4
    WD5
    WD6
    ZJD
  )

  MULTI_CODED_ELEMENTS = %w(
    ADU
    AFR
    AMN
    APH
    APP
    APS
    ATF
    BDI
    BFE
    BSM
    BTP
    CFE
    CMFE
    CMN
    CTD
    DOC
    ECRT
    ENS
    EQP
    EXT
    FEA
    FEN
    FLS
    FND
    FTP
    FTR
    GR
    GZC
    HOI
    HTC
    IMP
    IRS
    ITP
    LDE
    LDG
    LES
    LIC
    LIT
    LOC
    LTP
    LTV
    MHF
    MIF
    MTB
    OUT
    PARQ
    PKA
    PKG
    POS
    RDI
    RF
    RP
    RS2
    SIT
    SRI
    STP
    SWR
    TMC
    TPO
    TRM
    TYP
    UNF
    UTL
    VEW
    WAS
    WFT
    WTR
  )

  def self.find(conditions = {}, filters = [])
    unless conditions.is_a?(Hash)
      conditions = { :listing_number => conditions.to_i }
    end

    xml = Evernet::Connection.retrieve_listing_data(conditions, filters)
    collection = build_collection(xml)
    if conditions[:listing_number]
      collection.first
    else
      collection
    end
  end

  def self.listing_class(property_type)
    TYPE_TO_CLASS_MAP(property_type).constantize
  end

  def community
    if area
      @area_community ||= Nwmls::AreaCommunity.all.detect { |ac| ac.area == area }
      if @area_community
        @area_community.community
      end
    end
  end

  def listing_agent
    if listing_agent_number
      @listing_agent ||= Nwmls::Member.find listing_agent_number
    end
  end

  def co_listing_agent
    if co_listing_agent_number
      @co_listing_agent ||= Nwmls::Member.find co_listing_agent_number
    end
  end

  def selling_agent
    if selling_agent_number
      @selling_agent ||= Nwmls::Member.find selling_agent_number
    end
  end

  def selling_co_agent
    if selling_co_agent_number
      @selling_co_agent ||= Nwmls::Member.find selling_co_agent_number
    end
  end

  def co_office
    if co_office_number
      @co_office ||= Nwmls::Office.find co_office_number
    end
  end

  def selling_office
    if selling_office_number
      @selling_office ||= Nwmls::Office.find selling_office_number
    end
  end

  def selling_co_office
    if selling_co_office_number
      @selling_co_office ||= Nwmls::Office.find selling_co_office_number
    end
  end

  def history
    @history ||= Nwmls::ListingHistory.find listing_number
  end

  def office
    if listing_office_number
      @office ||= Nwmls::Office.find listing_office_number
    end
  end

  def school_district_description
    if school_district
      if found_school_district = Nwmls::SchoolDistrict.all.detect { |s| s.code == school_district }
        found_school_district.description
      end
    end
  end

  def images
    @images ||= Nwmls::Image.find(listing_number)
  end


  protected

  def self.listing_class(property_type)
    TYPE_TO_CLASS_MAP[property_type].constantize
  end

  def self.build_collection(xml)
    collection = []
    xml.root.children.each do |listing|
      attributes = {}
      klass = self.listing_class(listing.at_css('PTYP').inner_text)
      listing.children.each do |element|
        value = element.text
        name = element.name
        if value.present?
          key = klass.translate_attribute(element.name).to_sym
          if MULTI_CODED_ELEMENTS.include?(name)
            attributes[key] = value.split('|').collect { |val| I18n::t("#{name}.#{val}")}
          elsif CODED_ELEMENTS.include?(name)
            unless value == '0'
              attributes[key] = I18n::t("#{name}.#{value}")
            end
          else
            attributes[key] = value
          end

          #temporary code for development/debugging
          if ::Rails.env.development?
            Array(attributes[key]).each do |part|
              if part.to_s =~ /translation missing/
                Rails.logger.info "MISSING #{key} #{part}"
              elsif %w(Y N).include? attributes[key] and %w(GRDX GRDY DRS DRP).exclude?(name)
                Rails.logger.info "YN for #{name}"
              end
            end
          end
        end
      end
      instance = klass.new(attributes)
      collection << instance
    end
    collection
  end

  def self.translate_attribute(attribute)
    if code = self.attribute_mappings[attribute]
      code.underscore.parameterize('_')
    elsif Rails.env.development?
      raise "code #{attribute} not found"
    end
  end

end
