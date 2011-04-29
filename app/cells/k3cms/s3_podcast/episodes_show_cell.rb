module K3cms
  module S3Podcast
    class EpisodesShowCell < EpisodesCell
      def choose
        send(::Rails.application.config.k3cms_s3_show_view || :page)
      end
      
      def page
        setup
        render
      end
      
      def lightbox
        setup
        render
      end
    end
  end
end
