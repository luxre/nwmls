class NwmlsGenerator < Rails::Generators::Base
  argument :user_id, :type => :string, :default => "USER_ID"  
  argument :password, :type => :string, :default => "PASSWORD"  
  argument :schema_name, :type => :string, :default => Evernet::Connection::DEFAULT_SCHEMA_NAME

  desc "generator nwmls intializer file"
  def create_nwmls_file
    initializer "nwmls.rb" do
      data = ''
      data << "Evernet::Connection.user = '#{user_id}'\n"
      data << "Evernet::Connection.pass = '#{password}'\n"
      data << "Evernet::Connection.schema_name = '#{schema_name}'\n"
      data
    end
  end
end
