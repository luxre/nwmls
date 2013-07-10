class Nwmls::AreaCommunity
  attr_accessor :area, :community

  def self.all
    @@all ||= build_collection(Evernet::Connection.retrieve_area_community_data)
  end

  private

  def initialize(area, community)
    self.area = area
    self.community = community
  end

  def self.build_collection(xml)
    collection = []
    xml.root.children.each do |area_community|
      area = nil; community = nil;
      area_community.children.each do |child|
        if child.name == 'Area'
          area = child.text
        elsif child.name == 'Community'
          community = child.text
        end
      end
      collection << new(area, community)
    end
    collection
  end

end
