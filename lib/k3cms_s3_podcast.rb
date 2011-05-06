$:.unshift File.join(File.dirname(__FILE__), '..')  # so we can require 'app/models/...'

module K3cms
  module S3Podcast
  end
end

require 'k3cms/s3_podcast/engine'
require_relative 'uri_validator'
