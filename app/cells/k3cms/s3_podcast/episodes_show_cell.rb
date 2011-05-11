module K3cms
  module S3Podcast
    class EpisodesShowCell < EpisodesCell
      def show
        set_up
       #render :view => ::Rails.application.config.k3cms.s3_podcast.show_view
        render :view => :page
      end
    end
  end
end
