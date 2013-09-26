class Nwmls::Listing
  include Nwmls::Model
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

  BOOLEAN_ELEMENTS = %w[
    AFH
    AGR
    AllowAVM
    BON
    BREO
    BUS
    CL
    COO
    DW1
    DW2
    DW3
    DW4
    DW5
    DW6
    ENV
    EXA
    FAC
    FG1
    FG2
    FG3
    FG4
    FG5
    FG6
    FRN
    FUR
    LNI
    LNM
    LSI
    MFY
    NIA
    PAD
    PAS
    PTO
    ProhibitBLOG
    REM
    RO1
    RO2
    RO3
    RO4
    RO5
    RO6
    SDA
    SEP
    SFA
    SHOADR
    SIN
    SKS
    SML
    SNR
    SPA
    STO
    UBG
    UCS
    WD1
    WD2
    WD3
    WD4
    WD5
    WD6
  ]

  CODED_ELEMENTS = %w[
    ANC
    APR
    ARC
    BDC
    BRM
    DNO
    DRM
    EFR
    ELE
    ENT
    F17
    FAM
    FMR
    GAS
    KES
    KEY
    KIT
    LRM
    LTG
    MBD
    NC
    OTR
    POL
    PTYP
    RRM
    ST
    STY
    TOF
    UTR
    ZJD
  ]

  MULTI_CODED_ELEMENTS = %w[
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
    LEQ
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
  ]

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

  ###
  ### Relationships
  ###

  def co_listing_agent
    if co_listing_agent_number
      @co_listing_agent ||= Nwmls::Member.find co_listing_agent_number
    end
  end

  def co_office
    if co_office_number
      @co_office ||= Nwmls::Office.find co_office_number
    end
  end

  def communities
    if area
      @area_communities ||= Nwmls::AreaCommunity.all.select { |ac| ac.area == area }
      if @area_communities
        @area_communities.collect(&:community)
      end
    end
  end

  def history
    @history ||= Nwmls::ListingHistory.find listing_number
  end

  def images
    @images ||= Nwmls::Image.find(listing_number)
  end

  def listing_agent
    if listing_agent_number
      @listing_agent ||= Nwmls::Member.find listing_agent_number
    end
  end

  def office
    if listing_office_number
      @office ||= Nwmls::Office.find listing_office_number
    end
  end

  def school_district
    if school_district_code
      if @school_district ||= Nwmls::SchoolDistrict.all.detect { |s| s.code == school_district_code }
        @school_district.description
      end
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

  def selling_co_office
    if selling_co_office_number
      @selling_co_office ||= Nwmls::Office.find selling_co_office_number
    end
  end

  def selling_office
    if selling_office_number
      @selling_office ||= Nwmls::Office.find selling_office_number
    end
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
          if self.expand_attributes?
            key = klass.translate_attribute(element.name).to_sym
            if MULTI_CODED_ELEMENTS.include?(name)
              attributes[key] = value.split('|').collect { |val| I18n::t("#{name}.#{val}")}
            elsif CODED_ELEMENTS.include?(name)
              unless value == '0'
                attributes[key] = I18n::t("#{name}.#{value}")
              end
            elsif BOOLEAN_ELEMENTS.include?(name) and value
              attributes[key] = if value == 'Y'
                                  true
                                elsif value == 'N'
                                  false
                                else
                                  Rails.logger.info "BOOLEAN ELEMENT #{name} with value #{value}"
                                  nil
                                end
            else
              attributes[key] = value
            end
          else
            attributes[element.name] = value
          end

          #temporary code for development/debugging
          if ::Rails.env.development?
            Array(attributes[key]).each do |part|
              if part.to_s =~ /translation missing/
                Rails.logger.info "MISSING #{key} #{part}"
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

  ###
  ### Attribute Getters
  ###

  unless expand_attributes?
    def area
      self.AR
    end

    def co_listing_agent_number
      self.CLA
    end

    def co_office_number
      self.COLO
    end

    def listing_agent_number
      self.LAG
    end

    def listing_number
      self.LN
    end

    def listing_office_number
      self.LO
    end

    def selling_agent_number
      self.SAG
    end

    def selling_co_agent_number
      self.SCA
    end

    def selling_office_number
      self.SO
    end

    def selling_co_office_number
      self.SCO
    end
    def school_district_code
      self.SD
    end
  end


end
