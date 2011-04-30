#---------------------------------------------------------------------------------------------------
require 'bundler'
Bundler::GemHelper.install_tasks

#---------------------------------------------------------------------------------------------------
desc "Generates a Gemfile that points to your local development copies of K3cms gems"
task :gemfile do
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
  K3cms::S3Podcast::GemfileGenerator.start
end

# Note: You can pass in args to the generator like this: rake test_app["--quiet --other-args"]
desc "Generate a Rails app (required to run specs)"
task :test_app, [:args] => :gemfile do |t, args|
  require '../lib/generators/test_app/generator'
  class K3cms::S3Podcast::TestAppGenerator < K3cms::Generators::TestAppGenerator
    def install_gems
      inside "test_app" do
        run 'rake k3cms:install'
      end
    end

    def migrate_db
      run_migrations
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
  end

  K3cms::S3Podcast::TestAppGenerator.start(args[:args].to_s.split(' '))
end

#---------------------------------------------------------------------------------------------------
require 'rspec/core/rake_task'

desc 'Default: Run spec and cucumber'
task :default => [:spec, :cucumber ]

desc 'Run specdoc'
RSpec::Core::RakeTask.new('specdoc') do |t|
  t.pattern = FileList['spec/**/*_spec.rb']
end

desc 'Run specs'
RSpec::Core::RakeTask.new('spec') do |t|
  t.pattern = FileList['spec/**/*_spec.rb']
end
#---------------------------------------------------------------------------------------------------
