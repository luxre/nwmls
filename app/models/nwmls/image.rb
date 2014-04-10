class Nwmls::Image
  include Nwmls::Model

  def self.attribute_names
    attrs = %w[MLNumber PictureFileName PictureHeight PictureWidth PictureDescription UploadedDateTime LastModifiedDateTime]
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
    build_collection(Evernet::Connection.retrieve_image_data(conditions))
  end

end
