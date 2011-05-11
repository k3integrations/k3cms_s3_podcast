#---------------------------------------------------------------------------------------------------
require_relative '../core/lib/k3cms/core/common_rake_tasks'

#---------------------------------------------------------------------------------------------------
desc "Generates a Gemfile that points to your local development copies of K3cms gems"
task :gemfile, [:args] do |t, args|
  require '../lib/generators/gemfile/generator'
  class K3cms::S3Podcast::GemfileGenerator < K3cms::Generators::GemfileGenerator
    source_root Pathname.new(__FILE__).dirname

  protected
    def k3cms_gems_for_gemfile
      <<-End
gem 'k3cms',                       :path => '#{Pathname.new(__FILE__).dirname + '..'}'
gem 'k3cms_trivial_authorization', :path => '#{Pathname.new(__FILE__).dirname + '../trivial_authorization'}'
gem 'k3cms_s3_podcast',            :path => '#{Pathname.new(__FILE__).dirname + '../s3_podcast'}'
      End
    end
  end
  K3cms::S3Podcast::GemfileGenerator.start(args[:args].to_s.split(' '))
end

#---------------------------------------------------------------------------------------------------
desc "Generate a Rails app (required to run specs)"
task :test_app, [:args] => :gemfile do |t, args|
# Note: You can pass in args to the generator like this: rake test_app["--verbose --other-args"]
# If you want to debug things are just see what's going on, use rake test_app[--verbose]

  require '../lib/generators/test_app/generator'
  class K3cms::S3Podcast::TestAppGenerator < K3cms::Generators::TestAppGenerator

    # This is so you can override the default database.yml with your own and it will generate the test_app with your custom database.yml
    # If spec/templates/config/database.mysql.yml exists, it will use it, otherwise it will use ../lib/generators/test_app/templates/config/database.mysql.yml
    def self.source_paths
      [ Pathname.new(__FILE__).dirname + 'spec/templates' ]
    end

    # Override this task from the superclass
    # We need to ensure that it uses mysql for the database.yml and not the default of sqlite
    def create_databases_yml
      #puts "source_paths_for_search=#{self.class.source_paths_for_search.inspect}"
      template "config/database.mysql.yml", "config/database.yml", :force => true
      #inside(".") { run "pwd >&2; cat config/database.yml >&2" }
    end

    def root_route
      route :to => "k3cms/s3_podcast/episodes#index"
    end

    def s3_podcast_initializer
      generate 'k3cms_s3_podcast_initializer', 'my_bucket'
    end

  protected
    def create_bootstrap_test_app_gemfile_for_devise
      K3cms::S3Podcast::GemfileGenerator.start(['--no-include-k3cms-gems', '--quiet'])
    end

    def db_create?
      true
    end
  end

  K3cms::S3Podcast::TestAppGenerator.start(args[:args].to_s.split(' '))
end
