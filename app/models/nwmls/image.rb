class Nwmls::Image

  attr_accessor :ml_number, :picture_file_name, :picture_height, :picture_width, :picture_description, :uploaded_date_time, :last_modified_date_time

  def self.find(conditions = {})
    unless conditions.is_a?(Hash)
      conditions = { :listing_number => conditions.to_i }
    end
    build_collection(Evernet::Connection.retrieve_image_data(conditions))

  end

  private

  def self.build_collection(xml)
    collection = []
    xml.root.children.each do |image|
      attributes = {}
      image.children.each do |attribute|
        attributes[attribute.name.underscore] = attribute.text
      end
      collection << new(attributes)
    end
    collection
  end

  def initialize(attributes = {})
    self.ml_number = attributes['ml_number']
    self.picture_file_name = attributes['picture_file_name']
    self.picture_height = attributes['picture_height']
    self.picture_width = attributes['picture_width']
    self.picture_description = attributes['picture_description']
    self.uploaded_date_time = attributes['uploaded_date_time']
    self.last_modified_date_time = attributes['last_modified_date_time']
  end


end
