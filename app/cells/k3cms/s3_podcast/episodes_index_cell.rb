module K3cms
  module S3Podcast
    class EpisodesIndexCell < EpisodesCell

      #---------------------------------------------------------------------------------------------
      # These views show many episodes (within .k3cms_s3_podcast_episode_list)

      def index
        fetch_episodes
        render :view => ::Rails.application.config.k3cms.s3_podcast.index_view
      end

      def random
        @episodes = Episode.published.random
        options[:limit] ||= 3
        options[:pagination] = false if options[:pagination].nil?
        options[:text_for_header] ||= '<h2>Other Episodes</h2>'.html_safe
        index
      end

      def most_recent
        @episodes = Episode.published.most_recent
        options[:limit] ||= 6
        options[:pagination] = false if options[:pagination].nil?
        options[:text_for_header] ||= '<h2>Most Recent</h2>'.html_safe
        index
      end

      def related
        options[:to] or raise("to is required")
        @episodes = options[:to].related.most_recent
        options[:limit] ||= 3
        options[:pagination] = false if options[:pagination].nil?
        options[:text_for_header] ||= '<h2>Related Episodes</h2>'.html_safe
        index
      end

      #---------------------------------------------------------------------------------------------
      # These views show a single episode

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
        @episodes = @episodes.limit(options[:limit]) if options[:limit]
        # This is to enforce the episode.published? condition specified in a block. accessible_by doesn't automatically check the block conditions when fetching records.
        @episodes.select! {|episode| can?(:read, episode)}
      end
    end
  end
end
