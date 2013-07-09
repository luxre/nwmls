class Nwmls::SchoolDistrict

  attr_accessor :code, :description

  def self.all
    @@all ||= build_collection(Evernet::Connection.retrieve_school_data)
  end

  private

  def self.build_collection(xml)
    collection = []
    xml.root.children.each do |school|
      code = nil; description = nil;
      school.children.each do |child|
        if child.name == 'SchoolDistrictCode'
          code = child.text
        elsif child.name == 'SchoolDistrictDescription'
          description = child.text
        end
      end
      collection << new(code, description)
    end
    collection
  end

  def initialize(code, description)
    self.code = code
    self.description = description
  end
end
