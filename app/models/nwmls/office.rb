class Nwmls::Office
  include ActiveModel::Model
  attr_accessor :office_mlsid, :office_name, :street_care_of, :street_address, :street_city, :street_state, :street_zip_code, :street_zip_plus4, :street_county, :office_area_code, :office_phone, :fax_area_code, :fax_phone, :e_mail_address, :web_page_address, :office_type

  def self.all
    @@all ||= build_collection(Evernet::Connection.retrieve_office_data)
  end

  private

  def self.build_collection(xml)
    collection = []
    xml.root.children.each do |office|
      attributes = {}
      office.children.each do |child|
        attributes[child.name.underscore] = child.text
      end
      collection << new(attributes)
    end
    collection
  end

end
