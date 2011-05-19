module K3cms
  module S3Podcast
    class EpisodesIndexCell < EpisodesCell

      #---------------------------------------------------------------------------------------------
      def index
        fetch_episodes
        render :view => ::Rails.application.config.k3cms.s3_podcast.index_view
      end

      #---------------------------------------------------------------------------------------------
      def show
        set_up
        raise 'episode is required' unless @episode
        raise 'podcast is required' unless @podcast
        render :view => (::Rails.application.config.k3cms.s3_podcast.index_view == :tiles ? :tile : :table_row)
      end

      def table_row
        set_up
        raise 'episode is required' unless @episode
        raise 'podcast is required' unless @podcast
        render :view => 'table_row'
      end
      
      def tile
        set_up
        raise 'episode is required' unless @episode
        raise 'podcast is required' unless @podcast
        render :view => 'tile'
      end

      #---------------------------------------------------------------------------------------------
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
