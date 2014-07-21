class Nwmls::SchoolDistrict
  include Nwmls::Model

  def self.attribute_names
    if expand_attributes?
      [:code, :description]
    else
      [:Code, :Description]
    end
  end

  attr_accessor(*attribute_names)

  def self.all
    @@all ||= build_collection(Evernet::Connection.retrieve_school_data)
  end

  private

  def self.build_collection(xml)
    collection = []
    xml.root.children.each do |school|
      attributes = {}
      school.children.each do |child|
        if child.name == 'SchoolDistrictCode'
          attributes['Code'] = child.text
        elsif child.name == 'SchoolDistrictDescription'
          attributes['Description'] = child.text
        end
      end
      if self.expand_attributes?
        attributes = Hash[attributes.collect { |k, v| [k.downcase, v] }]
      end
      collection << new(attributes)
    end
    collection
  end
end
