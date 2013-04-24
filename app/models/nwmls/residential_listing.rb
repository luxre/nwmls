class Nwmls::ResidentialListing < Nwmls::Listing
  def self.find(conditions = {}, filters = [])
    if conditions.is_a?(Hash)
      conditions.merge!(:property_type => 'RESI')
    end
    super(conditions, filters)
  end
end
