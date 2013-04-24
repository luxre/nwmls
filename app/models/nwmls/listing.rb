#BUSO: 
#token: BusinessOpportunity
#COMI: 
#token: CommercialIndustrial
#FARM: 
#token: FarmRanch
#MANU: 
#token: Manufactured
#MULT: 
#token: MultiFamily
#RENT: 
#token: Rental
#RESI: 
#token: VacantLand
require 'nwmls_listing_codes'

class Nwmls::Listing
  include ActiveModel::Model
  include NwmlsListingCodes
  RESIDENTIAL_CODES.values.collect { |v| v.underscore.parameterize('_').to_sym }.each do |attr|
    attr_accessor attr
  end

  def self.find(conditions = {}, filters = [])
    unless conditions.is_a?(Hash)
      conditions = { :id => conditions.to_i }
    end

    response = evernet_client.call :retrieve_listing_data, message: { v_strXmlQuery: build_query(conditions, filters) }
    body = response.body[:retrieve_listing_data_response][:retrieve_listing_data_result]
    collection = []
    xml = Nokogiri::XML(body)
    xml.root.children.each do |listing|
      attributes = {}
      listing.children.each do |element|
        attributes[translate_attribute(element.name).to_sym] = element.text
      end
      klass = self.listing_class(attributes[:property_type])
      collection << klass.new(attributes)
    end
    if conditions[:id]
      collection.first
    else
      collection
    end
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
            if conditions[:id]
              xml.ListingNumber conditions[:id] if conditions[:id]
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
    if code = RESIDENTIAL_CODES[attribute]
      code.underscore.parameterize('_')
#    else
#      raise "code #{attribute} not found"
    end
  end

  def id
    self.listing_number
  end

  def self.listing_class(property_type)
    case property_type
    when "RESI" then Nwmls::ResidentialListing
    when "COND" then Nwmls::CondoListing
    end
  end


end
