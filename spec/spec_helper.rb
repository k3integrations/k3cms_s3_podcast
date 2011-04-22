require 'facets'
require 'rails'
require 'action_pack'
require 'action_view/railtie' # So that config.action_view is available in engine.rb
require 'active_record'       # Make sure this gets required before attribute_normalizer
require 'cells'
Bundler.require(:default, :development)

require File.expand_path('../../lib/k3cms_s3_podcast', __FILE__)

require 'connection_and_schema'


class User < ActiveRecord::Base
end

module TestApp
  class Application < Rails::Application
    config.active_support.deprecation = :stderr
  end
end
TestApp::Application.initialize!

require 'rspec/rails'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  config.include AttributeNormalizer::RSpecMatcher
end
