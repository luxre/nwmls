require 'nwmls/acts_as_nwmls_listing'

class Nwmls::Listing
  include Nwmls::ActsAsNwmlsListing

  CODED_FIELDS = %w(
    PTYP
    AGR
    AMP
    BLK
    BON
    BR1
    BR2
    BR3
    BR4
    BR5
    BR6
    BRI
    BUS
    CRI
    DW1
    DW2
    DW3
    DW4
    DW5
    DW6
    ELE
    ENV
    EQI
    EQV
    ESM
    FAC
    FG1
    FG2
    FG3
    FG4
    FG5
    FG6
    FP1
    FP2
    FP3
    FP4
    FP5
    FP6
    FRN
    FUR
    GAS
    GRM
    HET
    HOD
    INS
    LSD
    LSI
    LSZ
    MLT
    NAS
    NC
    NIA
    NOH
    NOU
    OTX
    PAD
    PKS
    POL
    RD
    REM
    RN1
    RN2
    RN3
    RN4
    RN5
    RN6
    RO1
    RO2
    RO3
    RO4
    RO5
    RO6
    SF1
    SF2
    SF3
    SF4
    SF5
    SF6
    SFF
    SHOADR
    SIB
    SLP
    SML
    SNR
    SPR
    ST
    STG
    STP
    TAC
    TIN
    TPO
    TYP
    UCS
    UFN
    UN1
    UN2
    UN3
    UN4
    UN5
    UN6
    UNF
    UTL
    WD1
    WD2
    WD3
    WD4
    WD5
    WD6
    WDW
    WFG
    WHT
    WTR
    ZJD
  )
  

  MULTI_CODED_FIELDS = %w(
    CFE
    FND
    AMN
    APP
    APS
    BDI
    BFE
    BSM
    BTP
    CMN
    CTD
    ENS
    EQP
    EXT
    FEA
    FEN
    FLS
    FTP
    FTR
    GR
    GZC
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
    SFS
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
        if value.include?('|') and not MULTI_CODED_FIELDS.include?(name)
          Rails.logger.info "MULTI #{name}"
        elsif value.length == 1 and not (CODED_FIELDS + MULTI_CODED_FIELDS).include?(name)
          Rails.logger.info "CODED #{name}"
        end
        if value.present?
          key = klass.translate_attribute(element.name).to_sym
          if MULTI_CODED_FIELDS.include?(name)
            attributes[key] = value.split('|').collect { |val| I18n::t("#{name}.#{val}")}
          elsif CODED_FIELDS.include?(name)
            unless value == '0'
              attributes[key] = I18n::t("#{name}.#{value}")
            end
          else
            if %w(Y N).include?(value)
              Rails.logger.info "YN for #{name}"
            end
            attributes[key] = value
          end
          if attributes[key].to_s =~ /translation missing/
            Rails.logger.info "MISSING #{key} #{attributes[key]}"
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
