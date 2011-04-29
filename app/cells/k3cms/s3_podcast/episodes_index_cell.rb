module K3cms
  module S3Podcast
    class EpisodesIndexCell < EpisodesCell
      def choose
        send(::Rails.application.config.k3cms_s3_index_view || :tiles)
      end
      
      def list
        fetch_episodes
        render :view => 'list'
      end
      
      def tiles
        fetch_episodes
        render :view => 'tiles' # Must specify because of choose() above...
      end
      
      def tile
        fetch_episodes
        render :view => 'tile'
      end
      
      private
      
      def fetch_episodes
        set_up
        unless @episodes
          @episodes = Episode.accessible_by(current_ability).order('id desc')
        end
        @episodes = @episodes.page(params[:page])
        # This is to enforce the episode.published? condition specified in a block. accessible_by doesn't automatically check the block conditions when fetching records.
        @episodes.select! {|episode| can?(:read, episode)}
      end
    end
  end
end
