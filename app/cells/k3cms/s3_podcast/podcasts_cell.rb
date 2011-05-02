module K3cms
  module S3Podcast
    class PodcastsCell < Cell::Rails
      helper K3cms::Ribbon::RibbonHelper # for edit_mode?
      #include K3cms::Ribbon::RibbonHelper # for edit_mode?
      helper K3cms::InlineEditor::InlineEditorHelper
      helper K3cms::S3Podcast::PodcastHelper
      helper K3cms::S3Podcast::EpisodeHelper

      def current_ability
        @current_ability ||= K3cms::S3Podcast::Ability.new(k3cms_user)
      end

      def list
        set_up
        unless @podcasts
          @podcasts = Podcast.accessible_by(current_ability).order('id desc')
        end
        #@podcasts = @podcasts.page(params[:page])

        # This is to enforce the podcast.published? condition specified in a block. accessible_by doesn't automatically check the block conditions when fetching records.
        @podcasts.select! {|podcast| can?(:read, podcast)}

        render
      end

      def show
        set_up
        @most_recent_episode = @podcast.episodes.published.last
        render
      end

      def published_status
        set_up
        render
      end

      def context_ribbon
        set_up
        render
      end

    private
      def set_up
        @podcast = options[:podcast]
        @podcasts = options[:podcasts]
      end

    end
  end
end
