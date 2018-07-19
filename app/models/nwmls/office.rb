class Nwmls::Office
  include Nwmls::Model

  def self.attribute_names
    attrs = %w[ OfficeMLSID OfficeName StreetCareOf StreetAddress StreetCity
      StreetState StreetZipCode StreetZipPlus4 StreetCounty OfficeAreaCode
      OfficePhone FaxAreaCode FaxPhone EMailAddress WebPageAddress OfficeType
    ]
    if expand_attributes?
      attrs = attrs.collect { |attr| attr.underscore }
    end
    attrs.collect { |attr| attr.to_sym }
  end

  attr_accessor(*attribute_names)

  def self.find(conditions = {})
    unless conditions.is_a?(Hash)
      conditions = { :office_mls_id => conditions.to_i }
    end
    collection = build_collection(Evernet::Query.retrieve_office_data(conditions))
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

  private

  unless expand_attributes?
    def office_mlsid
      self.OfficeMLSID
    end
  end

end
