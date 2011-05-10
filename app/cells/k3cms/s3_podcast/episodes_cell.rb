module K3cms
  module S3Podcast
    class EpisodesCell < Cell::Rails
      helper K3cms::Ribbon::RibbonHelper # for edit_mode?
      #include K3cms::Ribbon::RibbonHelper # for edit_mode?
      helper K3cms::InlineEditor::InlineEditorHelper
      helper K3cms::S3Podcast::EpisodeHelper

      # Sorry this is duplicated between here and app/controllers/k3cms/s3_podcast/base_controller.rb
      # I tried refactoring the common code out to a BaseControllerModule module that got mixed in both places, but for whatever reason that I couldn't figure out, it would use the current_ability defined in cancan/lib/cancan/controller_additions.rb:277:
      #   def current_ability
      #     @current_ability ||= ::Ability.new(current_user)
      #   end
      # which references non-existent Ability class.
      #
      def current_ability
        @current_ability ||= K3cms::S3Podcast::Ability.new(k3cms_user)
      end

      def published_status
        set_up
        render
      end
      
      def context_ribbon
        set_up
        render
      end

      def record_js
        set_up
        raise 'episode is required' unless @episode
        raise 'podcast is required' unless @podcast
        render
      end
      
    private
      
      # Extracts from options hash and sets instance variables
      # Initializes @new_episode
      def set_up
        @episode = options[:episode]
        @episodes = options[:episodes]

        @podcast = options[:podcast] || @episode.podcast

        # duplicated with #new action in controller
        @new_episode = K3cms::S3Podcast::Episode.new.set_defaults
        @new_episode.podcast = @podcast

        @style = options[:style]
      end
    end
  end
end
