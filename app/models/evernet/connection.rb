require 'savon'
class Evernet::Connection

  DEFAULT_SCHEMA_NAME = 'StandardXML1_2'
  cattr_accessor :user, :pass, :schema_name

  attr_accessor :client

  def wsdl
    raise "abstract: define in subclass"
  end

  private

  def self.instance
    @__instance__ ||= new
  end

  def initialize
    self.client = Savon.client(
      wsdl: wsdl,
      convert_request_keys_to: :none,
    )
  end

  def self.sanitize_conditions(conditions)
    conditions.each do |key,value|
      if [:begin_date, :end_date].include?(key.to_sym) and value.is_a?(String)
        conditions[key] = Time.parse(value)
      end
    end
    conditions
  end

end

class Nwmls::ConnectionError < StandardError
end
