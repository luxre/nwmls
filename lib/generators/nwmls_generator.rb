class NwmlsGenerator < Rails::Generators::Base
  argument :user_id, :type => :string, :default => "<%= ENV['NWMLS_USER_ID'] %>"
  argument :password, :type => :string, :default => "<%= ENV['NWMLS_PASSWORD'] %>"
  argument :schema_name, :type => :string, :default => Evernet::Connection::DEFAULT_SCHEMA_NAME

  desc "generator nwmls intializer file"
  def create_nwmls_file
    initializer "nwmls.rb" do
      data = ''
      data << "Nwmls.configure do |config|\n"
        data << "  config.user = '#{user_id}'\n"
        data << "  config.pass = '#{password}'\n"
        data << "  config.schema_name = '#{schema_name}'\n"
      data << "end\n"
      data
    end
  end
end
