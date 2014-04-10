class Nwmls::Amenity
  include Nwmls::Model

  if expand_attributes?
    attr_accessor :code, :description, :values
  else
    attr_accessor :Code, :Description, :Values
  end

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
        raw[code]['Code'] = code
        raw[code]['Description'] ||= amenity.at('Description').inner_text
        raw[code]['Values'] ||= {}
        raw[code]['Values'][amenity.at('Values Code').inner_text] = amenity.at('Values Description').inner_text
      end
    end
    if self.expand_attributes?
      raw = Hash[raw.collect { |k,v| [k.downcase, v] } ]
    end
    raw.each do |key,values|
      collection << self.new(values)
    end
    collection
  end

end
