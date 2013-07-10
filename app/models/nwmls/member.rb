class Nwmls::Member
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

  def office
    @office ||= Nwmls::Office.find office_mlsid
  end

  private

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
