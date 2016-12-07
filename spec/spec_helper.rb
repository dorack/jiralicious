$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "lib"))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require "rspec"
require "fakeweb"
require "jiralicious"

FakeWeb.allow_net_connect = false

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  config.include ConfigurationHelper
  config.include LoginHelper
  config.include JsonResponse

  config.before(:each) do
    configure_jiralicious
    register_login
  end
end
