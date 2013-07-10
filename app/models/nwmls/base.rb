class Nwmls::Base

  protected

  def self.build_collection(xml)
    collection = []
    xml.root.children.each do |office|
      attributes = {}
      office.children.each do |child|
        attributes[child.name.underscore] = child.text
      end
      collection << new(attributes)
    end
    collection
  end

  def initialize(params={})
    params.each do |attr, value|
      self.public_send("#{attr}=", value)
    end
  end

end
