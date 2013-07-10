class Nwmls::ListingHistory
  attr_accessor :ml_number, :list_price, :change_date

  def self.find(conditions = {})
    unless conditions.is_a?(Hash)
      conditions = { :listing_number => conditions.to_i }
    end
    build_collection(Evernet::Connection.retrieve_listing_history_data(conditions))
  end

  private

  def self.build_collection(xml)
    collection = []
    xml.root.children.each do |history|
      attributes = {}
      history.children.each do |attribute|
        attributes[attribute.name.underscore] = attribute.text
      end
      collection << new(attributes)
    end
    collection
  end

  def initialize(attributes)
    self.ml_number = attributes['ml_number']
    self.list_price = attributes['list_price']
    self.change_date = attributes['change_date']
  end
 
end
