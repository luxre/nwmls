class Nwmls::CondoListing < Nwmls::Listing
  def self.find(conditions = {}, filters = [])
    if conditions.is_a?(Hash)
      conditions.merge!(:property_type => 'COND')
    end
    super(conditions, filters)
  end
end
