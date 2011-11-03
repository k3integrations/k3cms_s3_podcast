require "rails"
require "k3cms/core/railtie"
require "k3cms_s3_podcast"
require 'facets/kernel/__dir__'
require 'facets/pathname'

module K3cms
  module S3Podcast
    class Railtie < Rails::Engine
      puts self

      config.k3cms.s3_podcast = ActiveSupport::OrderedOptions.new

      config.before_configuration do |app|
        # Ensure that active_record is loaded before attribute_normalizer, since attribute_normalizer only loads its active_record-specific code if active_record is loaded.
        require 'active_record'
        require 'kaminari'
        require 'attribute_normalizer'

        # See ./lib/generators/k3cms_s3_podcast_initializer/templates/initializer.rb.erb
        config.k3cms.s3_podcast.video_tag_options = {}
        config.k3cms.s3_podcast.pagination = {
          :per_row => 3, :per_page => 12
        }
        config.k3cms.s3_podcast.index_view = :tiles # :table or :tiles
        config.k3cms.s3_podcast.show_view  = :page  # :lightbox or :page
      end

      config.before_initialize do
        # Anything in the .gemspec that needs to be *required* should be required here.
        # This is a workaround for the fact that this line:
        #   Bundler.require(:default, Rails.env) if defined?(Bundler)
        # in config/application.rb only does a 'require' for the gems explicitly listed in the *app*'s Gemfile -- not for the gems *they* might depend on (which are listed in a .gemspec file, not a Gemfile).
        require 'haml'
        require 'acts-as-taggable-on'
        require 'aws/s3'
        require 'validates_timeliness'
        require 'cancan'
      end

      # This is to avoid errors like undefined method `can?' for #<K3cms::S3Podcast::EpisodesCell>
      initializer 'k3cms.s3_podcast.cancan' do
        ActiveSupport.on_load(:action_controller) do
          include CanCan::ControllerAdditions
          Cell::Base.send :include, CanCan::ControllerAdditions
        end
      end

      config.action_view.javascript_expansions[:k3cms].concat [
        'k3cms/video.js',
        'k3cms/s3_podcast.js',
        'jquery.tools.min.js',
        'k3cms/jquery.jplayer.min.js',
      ]
      config.action_view.javascript_expansions[:k3cms_editing].concat [
        'jquery.tools.tooltip.js',
      ]
      config.action_view.stylesheet_expansions[:k3cms] ||= []
      config.action_view.stylesheet_expansions[:k3cms].concat [
        'k3cms/s3_podcast.css',
        'k3cms/s3_podcast_overlay.css',
        'k3cms/video-js.css',
        'k3cms/jquery.jplayer/jplayer.blue.monday.css',
        'k3cms/jquery.jplayer/jplayer.blue.monday.overrides.css',
      ]

      initializer 'k3cms.s3_podcast.cells_paths' do |app|
        Cell::Base.view_paths += [config.root + 'app/cells',
                                  config.root + 'app/views']
      end

      initializer 'k3cms.s3_podcast.action_view' do
        ActiveSupport.on_load(:action_view) do
          #include K3cms::S3Podcast::S3PodcastHelper
        end
      end

      config.after_initialize do
        Cell::Rails.class_eval do
          helper K3cms::S3Podcast::EpisodeHelper
          helper K3cms::S3Podcast::PodcastHelper
        end
        ApplicationController.class_eval do
          helper K3cms::S3Podcast::EpisodeHelper
          helper K3cms::S3Podcast::PodcastHelper
        end
      end

      initializer 'k3cms.s3_podcast.hooks', :before => 'k3cms.core.hook_listeners' do |app|
        class K3cms::S3Podcast::Hooks < K3cms::ThemeSupport::HookListener
          insert_after :top_of_page, :file => 'k3cms/s3_podcast/init.html.haml'
        end
      end

      initializer 'k3cms.s3_podcast.require_decorators', :after => 'k3cms.core.require_decorators' do |app|
        #puts 'k3cms.s3_podcast.require_decorators'
        Dir.glob(config.root + "app/**/*_decorator*.rb") do |c|
          Rails.env.production? ? require(c) : load(c)
        end
      end

    end
  end
end
