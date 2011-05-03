module K3cms
  module S3Podcast
    class EpisodesShowCell < EpisodesCell
      def choose
        send(::Rails.application.config.k3cms_s3_show_view || :page)
      end
      
      def page
        set_up
        render :view => 'page'
      end
      
      def lightbox
        set_up
        render :view => 'lightbox'
      end
    end
  end
end
