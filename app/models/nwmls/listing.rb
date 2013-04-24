require 'nwmls/acts_as_nwmls_listing'

class Nwmls::Listing
  include Nwmls::ActsAsNwmlsListing

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
      property_type = listing.at_css('PTYP').inner_text
      klass = self.listing_class(property_type)
      listing.children.each do |element|
        attributes[translate_attribute(element.name).to_sym] = element.text
      end
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
    if code = self.codes[attribute]
      code.underscore.parameterize('_')
#    else
#      raise "code #{attribute} not found"
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
