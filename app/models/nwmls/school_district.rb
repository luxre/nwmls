class Nwmls::SchoolDistrict
  include Nwmls::Base

  attr_accessor :code, :description

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
          attributes[:code] = child.text
        elsif child.name == 'SchoolDistrictDescription'
          attributes[:description] = child.text
        end
      end
      collection << new(attributes)
    end
    collection
  end

end
