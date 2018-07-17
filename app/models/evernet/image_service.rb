class Evernet::ImageService < Evernet::Connection

  def wsdl
    "http://images.idx.nwmls.com/imageservice/imagequery.asmx?WSDL"
  end

  def self.retrieve_image(conditions = {})
    response = instance.client.call :retrieve_images, message: { query: build_query(conditions) }
    raw = response.body[:retrieve_images_response][:retrieve_images_result]
    load_data_result_with_nokogiri(raw)
  end

  def self.build_query(conditions = {}, filters = [])
    conditions = self.sanitize_conditions(conditions)

    xml = Builder::XmlMarkup.new
    xml.instruct!
    xml.ImageQuery(:xmlns => "NWMLS: EverNet: ImageQuery: 1.0") do
      xml.Auth do
        xml.UserId Evernet::Connection.user
        xml.Password Evernet::Connection.pass
        xml.SchemaName (Evernet::Connection.schema_name || DEFAULT_SCHEMA_NAME )
      end
      xml.Query do
        if conditions[:listing_number]
          if conditions[:sequence]
            xml.BySequence do
              xml.ListingNumber conditions[:listing_number]
              xml.Sequence conditions[:sequence]
            end
          else
            xml.ByListingNumber conditions[:listing_number]
          end
        elsif conditions[:name]
          xml.ByName conditions[:name]
        end
      end
      xml.Results do
        xml.Schema "NWMLS:EverNet:ImageData:1.0"
      end
    end
  end

  def self.load_data_result_with_nokogiri(raw)
    xml = Nokogiri::XML(raw)
    xml.root.child
  end

end
