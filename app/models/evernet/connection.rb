require 'savon'
class Evernet::Connection

  SCHEMA_NAME = 'NWMLSStandardXML'
  MLS = 'NWMLS'
  DEFAULT_PTYP = 'RESI'

  cattr_accessor :user, :pass

  attr_accessor :client

  def self.retrieve_listing_data(conditions = {}, filters = [])
    response = instance.client.call :retrieve_listing_data, message: { v_strXmlQuery: build_query(conditions, filters) }
    response.body[:retrieve_listing_data_response][:retrieve_listing_data_result]
  end

  def self.retrieve_amenity_data(conditions = {}, filters = [])
    response = instance.client.call :retrieve_amenity_data, message: { v_strXmlQuery: build_query(conditions) }
    response.body[:retrieve_amenity_data_response][:retrieve_amenity_data_result]
  end

  private

  def self.instance
    @__instance__ ||= new
  end

  def initialize
    self.client = Savon.client(
      wsdl: "http://evernet.nwmls.com/evernetqueryservice/evernetquery.asmx?WSDL",
      convert_request_keys_to: :none,
    )
  end


  def self.build_query(conditions = {}, filters = [])
    xml = Builder::XmlMarkup.new
    xml.instruct!
    xml.EverNetQuerySpecification(:xmlns => "urn:www.nwmls.com/Schemas/General/EverNetQueryXML.xsd") do
      xml.Message do
        xml.Head do
          xml.UserId user
          xml.Password pass
          xml.SchemaName SCHEMA_NAME
        end
        xml.Body do
          xml.Query do
            xml.MLS MLS
            if conditions[:listing_number]
              xml.ListingNumber conditions[:listing_number] if conditions[:listing_number]
              xml.PropertyType (conditions[:property_type] || DEFAULT_PTYP)
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


end
