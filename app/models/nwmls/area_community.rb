class Nwmls::AreaCommunity
  include Nwmls::Model

  if expand_attributes?
    attr_accessor :area, :community
  else
    attr_accessor :Area, :Community
  end

  def self.all
    @@all ||= build_collection(Evernet::Connection.retrieve_area_community_data)
  end

end
