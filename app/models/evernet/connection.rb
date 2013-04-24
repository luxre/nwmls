require 'savon'
class Evernet::Connection
  cattr_accessor :user, :pass

  def self.new
    Savon.client(
      wsdl: "http://evernet.nwmls.com/evernetqueryservice/evernetquery.asmx?WSDL",
      convert_request_keys_to: :none,
    )
  end

end
