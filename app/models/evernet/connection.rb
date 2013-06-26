require 'savon'
class Evernet::Connection
  cattr_accessor :user, :pass
  attr_accessor :client

  def initialize
    self.client = Savon.client(
      wsdl: "http://evernet.nwmls.com/evernetqueryservice/evernetquery.asmx?WSDL",
      convert_request_keys_to: :none,
    )
  end

end
