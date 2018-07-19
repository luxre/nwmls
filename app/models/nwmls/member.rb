class Nwmls::Member
  include Nwmls::Model

  def self.attribute_names
    attrs = %w[ MemberMLSID FirstName LastName OfficeMLSID OfficeName OfficeAreaCode OfficePhone OfficePhoneExtension]
    if expand_attributes?
      attrs = attrs.collect { |attr| attr.underscore }
    end
    attrs.collect { |attr| attr.to_sym }
  end

  attr_accessor(*attribute_names)

  def self.find(conditions = {})
    unless conditions.is_a?(Hash)
      conditions = { :agent_mls_id => conditions.to_i }
    end
    collection = build_collection(Evernet::Query.retrieve_member_data(conditions))
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

  def listings
    @listings ||= Nwmls::Listing::TYPE_TO_CLASS_MAP.collect { |type, klass| public_send(klass.demodulize.underscore.pluralize) }.sum
  end

  def office
    @office ||= Nwmls::Office.find office_mlsid
  end

  private

  unless expand_attributes?
    def member_mlsid
      self.MemberMLSID
    end
  end

end
