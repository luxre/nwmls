require 'nwmls/acts_as_nwmls_listing'

class Nwmls::Listing
  include Nwmls::ActsAsNwmlsListing

  CODED_FIELDS = %w(
    AR
    ASF
    BUS
    CLA
    COLO
    DRP
    DRS
    EXT
    FP
    GAR
    GRDX
    GRDY
    HOD
    HSN
    HSNA
    LSD
    LSF
    MAP
    MOR
    NC
    NIA
    PIC
    POL
    PRJ
    SFF
    SHOADR
    SIT
    SML
    SNR
    ST
    STR
    TX
    TXY
    WHT
  )
  

  MULTI_CODED_FIELDS = %w(
    APS
    BDI
    ENS
    EXT
    FEA
    FLS
    GR
    HTC
    LDE
    RF
    SIT
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
      property_type = listing.at_css('PTYP').inner_text
      klass = self.listing_class(property_type)
      listing.children.each do |element|
        value = element.text
        name = element.name
        if value.include?('|') and not MULTI_CODED_FIELDS.include?(name)
          Rails.logger.info "MULTI #{name}"
        elsif value.length == 1 and not (CODED_FIELDS + MULTI_CODED_FIELDS).include?(name)
          Rails.logger.info "CODED #{name}"
        end
        key = klass.translate_attribute(element.name).to_sym
        #we should do the encoding here duh!
        attributes[key] = element.text
      end
      instance = klass.new(attributes)
      attributes.keys.each do |attr|
        val = instance.send(attr)
        if val.to_s =~ /translation missing/
          Rails.logger.info "MISSING #{attr} #{val}"

        end
      end
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
