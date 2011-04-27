# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "k3cms/s3_podcast/version"

Gem::Specification.new do |s|
  s.name          = "k3cms_s3_podcast"
  s.summary       = %q{K3cms S3Podcast}
  s.description   = %q{Simple podcast functionality for the K3cms using Amazon S3 for storage of podcast assets}
  s.homepage      = "http://k3cms.org/#{s.name}"

  s.authors       = `git shortlog --summary --numbered         | awk '{print $2, $3    }'`.split("\n")
  s.email         = `git shortlog --summary --numbered --email | awk '{print $2, $3, $4}'`.split("\n")

  s.add_dependency 'facets'
  s.add_dependency 'rails',        '~> 3.0.0'
  s.add_dependency 'activerecord', '~> 3.0.0'
  s.add_dependency 'actionpack',   '~> 3.0.0'
  s.add_dependency 'cancan'
  s.add_dependency 'k3cms_core'
  s.add_dependency 'k3cms_ribbon' # for edit_mode?
  s.add_dependency 'cells'
  s.add_dependency 'acts-as-taggable-on'
  s.add_dependency 'aws-s3' # :require => 'aws/s3'
  s.add_dependency 'kaminari' # pagination

  s.add_dependency 'attribute_normalizer'
  s.add_dependency 'validates_timeliness'

  # TODO: These are listed in the gem's Gemfile -- do we need to duplicate the list here as well?
 #s.add_development_dependency 'rspec'
 #s.add_development_dependency 'rspec-rails'
 #s.add_development_dependency 'machinist'
 #s.add_development_dependency 'sqlite3-ruby'
 #s.add_development_dependency 'ruby-debug19'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.version       = K3cms::S3Podcast::Version
  s.platform      = Gem::Platform::RUBY
end
