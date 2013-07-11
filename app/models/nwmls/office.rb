class Nwmls::Office
  include Nwmls::Model

  attr_accessor :office_mlsid, :office_name, :street_care_of, :street_address, :street_city, :street_state, :street_zip_code, :street_zip_plus4, :street_county, :office_area_code, :office_phone, :fax_area_code, :fax_phone, :e_mail_address, :web_page_address, :office_type

  def self.find(conditions = {})
    unless conditions.is_a?(Hash)
      conditions = { :office_mls_id => conditions.to_i }
    end
    collection = build_collection(Evernet::Connection.retrieve_office_data(conditions))
    if conditions[:office_mls_id]
      collection.first
    else
      collection
    end
  end

  def members
    @members ||= Nwmls::Member.find(:office_mls_id => office_mlsid)
  end

  Nwmls::Listing::TYPE_TO_CLASS_MAP.each do |type, klass|
    method_name = klass.demodulize.underscore.pluralize
    define_method method_name do
      unless instance_variable_get("@#{method_name}")
        instance_variable_set("@#{method_name}", klass.constantize.find(:office_mls_id => office_mlsid, :property_type => type))
      end
      instance_variable_get("@#{method_name}")
    end
  end

  def listings
    @listings ||= Nwmls::Listing::TYPE_TO_CLASS_MAP.collect { |type, klass| public_send(klass.demodulize.underscore.pluralize) }.sum
  end

end
