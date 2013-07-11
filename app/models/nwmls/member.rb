class Nwmls::Member < Nwmls::Base
  attr_accessor :member_mlsid, :first_name, :last_name, :office_mlsid, :office_name, :office_area_code, :office_phone, :office_phone_extension

  def self.find(conditions = {})
    unless conditions.is_a?(Hash)
      conditions = { :agent_mls_id => conditions.to_i }
    end
    collection = build_collection(Evernet::Connection.retrieve_member_data(conditions))
    if conditions[:agent_mls_id]
      collection.first
    else
      collection
    end
  end

  Nwmls::Listing::TYPE_TO_CLASS_MAP.each do |type, klass|
    method_name = klass.demodulize.underscore.pluralize
    define_method method_name do
      unless instance_variable_get("@#{method_name}")
        instance_variable_set("@#{method_name}", klass.constantize.find(:agent_mls_id => member_mlsid, :property_type => type))
      end
      instance_variable_get("@#{method_name}")
    end
  end

  def office
    @office ||= Nwmls::Office.find office_mlsid
  end

end
