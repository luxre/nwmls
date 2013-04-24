$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "nwmls/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "nwmls"
  s.version     = Nwmls::VERSION
  s.authors     = ["LRE Interactive"]
  s.email       = ["lre-interactive@luxuryrealestate.com"]
  s.homepage    = "http://www.luxuryrealestate.com"
  s.summary     = "Summary of Nwmls."
  s.description = "Description of Nwmls."

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.0.0.beta1"
  s.add_dependency "savon"
  s.add_dependency "nokogiri"

  s.add_development_dependency "sqlite3"
end
