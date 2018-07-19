require "nwmls/engine"
require "nwmls/model"
require "nwmls/acts_as_nwmls_listing"

module Nwmls
  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  class Configuration
    attr_accessor :user, :pass, :schema_name
  end

end
