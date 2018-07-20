class Nwmls::OpenHouse
  include Nwmls::Model

  def self.attribute_names
    attrs = %w[Id ModifiedDt ListingNumber BeginDt EndDt Description]
    if expand_attributes?
      attrs = attrs.collect { |attr| attr.underscore }
    end
    attrs.collect { |attr| attr.to_sym }
  end

  attr_accessor(*attribute_names)

  def self.find(conditions = {})
    build_collection(Evernet::Query.retrieve_open_house_data(conditions))
  end
end
