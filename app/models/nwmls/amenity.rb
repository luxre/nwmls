class Nwmls::Amenity < Nwmls::Base

  attr_accessor :code, :description, :values


  def self.find(property_type)
    xml = Evernet::Connection.retrieve_amenity_data(property_type)
    build_collection(xml)
  end

  protected

  def self.build_collection(xml)
    collection = []
    raw = {}
    xml.root.children.each do |amenity|
      if amenity.name == 'Amenity'
        code = amenity.at('Code').inner_text
        raw[code] ||= {}
        raw[code][:code] = code
        raw[code][:description] ||= amenity.at('Description').inner_text
        raw[code][:values] ||= {}
        raw[code][:values][amenity.at('Values Code').inner_text] = amenity.at('Values Description').inner_text
      end
    end
    raw.each do |key,values|
      collection << self.new(values)
    end
    collection
  end

end
