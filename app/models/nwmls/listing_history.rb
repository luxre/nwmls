class Nwmls::ListingHistory
  include Nwmls::Model

  attr_accessor :ml_number, :list_price, :change_date

  def self.find(conditions = {})
    unless conditions.is_a?(Hash)
      conditions = { :listing_number => conditions.to_i }
    end
    build_collection(Evernet::Connection.retrieve_listing_history_data(conditions))
  end

  def listing
    @listing ||= Nwmls::Listing.find ml_number
  end

end
