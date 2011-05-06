# Load the test application
ENV["RAILS_ENV"] ||= 'test'
require Pathname.new(__FILE__).dirname + 'test_app/config/environment'

require 'rspec/rails'
require 'rspec_tag_matchers'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| puts f;require f}

require Pathname.new(__FILE__).dirname + "blueprints"

RSpec.configure do |config|
  config.mock_with :rspec

  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  config.use_transactional_fixtures = true

  config.include AttributeNormalizer::RSpecMatcher
  config.include(RspecTagMatchers)

  include Devise::TestHelpers
end
