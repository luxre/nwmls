require 'nwmls/acts_as_nwmls_listing'

class Nwmls::Listing
  include Nwmls::ActsAsNwmlsListing

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
    PKA
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
    case property_type
    when "RESI" then Nwmls::ResidentialListing
    when "COND" then Nwmls::CondominiumListing
    when "BUSO" then Nwmls::BusinessOpportunityListing
    when "COMI" then Nwmls::CommercialListing
    when "FARM" then Nwmls::FarmListing
    when "MANU" then Nwmls::ManufacturedHomeListing 
    when "MULT" then Nwmls::MultiFamilyListing
    when "RENT" then Nwmls::RentalListing
    when "VACL" then Nwmls::VacantLandListing
    end
  end

  def office
    if listing_office_number
      @office ||= Nwmls::Office.all.detect { |o| o.office_mlsid == listing_office_number }
    end
  end


  protected

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
