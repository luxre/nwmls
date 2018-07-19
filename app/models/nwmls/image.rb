class Nwmls::Image
  include Nwmls::Model

  def self.attribute_names
    attrs = %w[ImageId ImageOrder UploadDt BLOB]
    if expand_attributes?
      attrs = attrs.collect { |attr| attr.underscore }
    end
    attrs.collect { |attr| attr.to_sym }
  end

  attr_accessor(*attribute_names)

  def self.find(conditions = {})
    unless conditions.is_a?(Hash)
     conditions = { :name => conditions }
    end
    collection = build_collection(Evernet::ImageService.retrieve_image(conditions))
    if conditions[:sequence].present? or conditions[:name].present?
      collection.first
    else
      collection
    end
  end

  def self.build_collection(root)
    collection = []
    root.children.each do |element|
      attributes = {}
      element.children.each do |child|
        key = expand_attributes? ? child.name.underscore : child.name
        if key.downcase == 'message'
          raise Nwmls::ConnectionError, child.text
        end
        attributes[key] = child.text
      end
      collection << new(attributes)
    end
    collection
  end


end
