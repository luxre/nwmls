class Nwmls::Image
  include Nwmls::Model

  attr_accessor :ml_number, :picture_file_name, :picture_height, :picture_width, :picture_description, :uploaded_date_time, :last_modified_date_time

  def self.find(conditions = {})
    unless conditions.is_a?(Hash)
      conditions = { :listing_number => conditions.to_i }
    end
    build_collection(Evernet::Connection.retrieve_image_data(conditions))

  end

end
