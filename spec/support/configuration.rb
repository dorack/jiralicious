module ConfigurationHelper
  def configure_jiralicious
    Jiralicious.configure do |config|
      config.username = "jstewart"
      config.password = "topsecret"
      config.uri = "http://localhost"
      config.api_version = "latest"
      config.auth_type = :cookie
    end
  end
end
