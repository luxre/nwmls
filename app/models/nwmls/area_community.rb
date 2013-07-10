class Nwmls::AreaCommunity < Nwmls::Base
  attr_accessor :area, :community

  def self.all
    @@all ||= build_collection(Evernet::Connection.retrieve_area_community_data)
  end

end
