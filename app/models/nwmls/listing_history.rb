class Nwmls::ListingHistory
  include Nwmls::Model

  def self.attribute_names
    attrs = %w[ML_Number ListPrice ChangeDate]
    if expand_attributes?
      attrs = attrs.collect { |attr| attr.underscore }
    end
    attrs.collect { |attr| attr.to_sym }
  end

  attr_accessor(*attribute_names)

  def self.find(conditions = {})
    unless conditions.is_a?(Hash)
      conditions = { :listing_number => conditions.to_i }
    end
    build_collection(Evernet::Connection.retrieve_listing_history_data(conditions))
  end

  def listing
    @listing ||= Nwmls::Listing.find ml_number
  end

  private

  unless expand_attributes?
    def ml_number
      self.ML_Number
    end
  end

end
