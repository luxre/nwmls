require 'nwmls/acts_as_nwmls_listing'

class Nwmls::Listing
  include Nwmls::ActsAsNwmlsListing

  CODED_ELEMENTS = %w(
    ADU
    AFH
    AFR
    AGR
    AMN
    AMP
    ANC
    APH
    APP
    APR
    APS
    ARC
    ATF
    BDC
    BDI
    BFE
    BON
    BREO
    BRM
    BSM
    BTP
    BUS
    CFE
    CL
    CMFE
    CMN
    COO
    CTD
    DNO
    DOC
    DRM
    DW1
    DW2
    DW3
    DW4
    DW5
    DW6
    ECRT
    EFR
    ELE
    ENS
    ENT
    ENV
    EQP
    EXA
    EXT
    F17
    FAC
    FAM
    FEA
    FEN
    FG1
    FG2
    FG3
    FG4
    FG5
    FG6
    FLS
    FMR
    FND
    FRN
    FTP
    FTR
    FUR
    GAS
    GR
    GZC
    HOI
    KES
    KEY
    KIT
    LDG
    LES
    LIC
    LIT
    LNI
    LNM
    LOC
    LOF
    LRM
    LTG
    LTV
    MBD
    MFY
    MTB
    NC
    NIA
    OTR
    PAD
    PARQ
    PAS
    PKA
    POL
    POS
    PTO
    PTYP
    REM
    RO1
    RO2
    RO3
    RO4
    RO5
    RO6
    RP
    RRM
    RS2
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
    STP
    STY
    TMC
    TOF
    TPO
    TYP
    UBG
    UCS
    UNF
    UTL
    UTR
    WAS
    WD1
    WD2
    WD3
    WD4
    WD5
    WD6
    WTR
    ZJD
  )

  MULTI_CODED_ELEMENTS = %w(
    HTC
    IMP
    IRS
    ITP
    LDE
    LTP
    MHF
    MIF
    OUT
    PKG
    RDI
    RF
    SIT
    SRI
    SWR
    TRM
    VEW
    WFT
  )

  def self.find(conditions = {}, filters = [])
    unless conditions.is_a?(Hash)
      conditions = { :listing_number => conditions.to_i }
    end

    response = evernet_client.call :retrieve_listing_data, message: { v_strXmlQuery: build_query(conditions, filters) }
    xml_body = response.body[:retrieve_listing_data_response][:retrieve_listing_data_result]
    collection = build_collection_from_xml(xml_body)
    if conditions[:listing_number]
      collection.first
    else
      collection
    end
  end

  def self.build_collection_from_xml(xml_body)
    collection = []
    xml = Nokogiri::XML(xml_body)
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
            if attributes[key].to_s =~ /translation missing/
              Rails.logger.info "MISSING #{key} #{attributes[key]}"
            elsif %w(Y N).include? attributes[key] and %w(GRDX GRDY DRS DRP).exclude?(name)
              Rails.logger.info "YN for #{name}"
            end
          end
        end
      end
      instance = klass.new(attributes)
      collection << instance
    end
    collection
  end

  def self.build_query(conditions = {}, filters = [])
    xml = Builder::XmlMarkup.new
    xml.instruct!
    xml.EverNetQuerySpecification(:xmlns => "urn:www.nwmls.com/Schemas/General/EverNetQueryXML.xsd") do
      xml.Message do
        xml.Head do
          xml.UserId Evernet::Connection.user
          xml.Password Evernet::Connection.pass
          xml.SchemaName 'NWMLSStandardXML'
        end
        xml.Body do
          xml.Query do
            xml.MLS "NWMLS"
            if conditions[:listing_number]
              xml.ListingNumber conditions[:listing_number] if conditions[:listing_number]
              xml.PropertyType (conditions[:property_type] || 'RESI')
            else
              xml.PropertyType conditions[:property_type]
              xml.Status conditions[:status] if conditions[:status]
              xml.County conditions[:county] if conditions[:county]
              xml.Area conditions[:area] if conditions[:area]
              xml.City conditions[:city]if conditions[:city]
              xml.BeginDate (conditions[:begin_date] or 10.years.ago).strftime('%FT%T')
              xml.EndDate (conditions[:end_date] or Time.now + 1.day).strftime('%FT%T')
              xml.OfficeId conditions[:office_mls_id] if conditions[:office_mls_id]
              xml.AgentId conditions[:agent_mls_id] if conditions[:agent_mls_id]
              xml.Bedrooms conditions[:bedrooms] if conditions[:bedrooms]
              xml.Bathrooms conditions[:bathrooms] if conditions[:bathrooms]
            end
          end
          xml.Filter filters.join(',')
        end
      end
    end
  end

  def self.evernet_client
    @@evernet_client ||= Evernet::Connection.new
  end

  def self.translate_attribute(attribute)
    if code = self.attribute_mappings[attribute]
      code.underscore.parameterize('_')
    else
      raise "code #{attribute} not found"
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

end
