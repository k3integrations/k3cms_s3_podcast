module K3cms
  module S3Podcast
    class EpisodesCell < Cell::Rails
      helper K3cms::Ribbon::RibbonHelper # for edit_mode?
      #include K3cms::Ribbon::RibbonHelper # for edit_mode?
      helper K3cms::InlineEditor::InlineEditorHelper
      helper K3cms::S3Podcast::S3PodcastHelper

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

      def list
        set_up
        unless @episodes
          @episodes = Episode.accessible_by(current_ability).order('id desc')
        end
        @episodes = @episodes.page(params[:page])
        # This is to enforce the episode.published? condition specified in a block. accessible_by doesn't automatically check the block conditions when fetching records.
        @episodes.select! {|episode| can?(:read, episode)}
        render
      end

      def published_status
        set_up
        render
      end

      def show_large
        set_up
        render
      end

      def show_small
        set_up
        render
      end

    private
      def set_up
        @episode = options[:episode]
        @episodes = options[:episodes]
      end

    end
  end
end
