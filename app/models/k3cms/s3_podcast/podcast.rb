module K3cms
  module S3Podcast
    class Podcast < ActiveRecord::Base
      set_table_name 'k3cms_s3_podcast_podcasts'

      has_many :episodes, :class_name => 'K3cms::S3Podcast::Episode'
      belongs_to :author, :class_name => 'User'

      normalize_attributes :title, :summary, :description, :with => [:strip, :blank]

      validates :episode_image_url, :icon_url, :logo_url, :uri => true, :allow_nil => true

      validates :title, :presence => true
      validates :episode_image_url, :presence => true, :if => :video?

      #---------------------------------------------------------------------------------------------
      # Sources

      serialize :episode_source_urls
      normalize_attributes :episode_source_urls, :with => [:reject_blank]

      after_initialize :initialize_episode_source_urls
      def initialize_episode_source_urls
        self.episode_source_urls ||= []
      end

      validate :validate_episode_source_urls
      def validate_episode_source_urls
        episode_source_urls.any? or (errors[:episode_source_urls] << "must include one source"; return)

        episode_source_urls.each do |source_url|
          validator = UriValidator.new(:attributes => [:episode_source_urls], :message => "contains invalid url '#{source_url}'")
          validator.validate_each self, :episode_source_urls, source_url
        end
      end

      class << self
        def image_extensions; %w[.png .jpg .gif]; end
        def video_extensions; %w[.mp4 .ogv .webmv .m4v]; end
        def audio_extensions; %w[.mp3 .oga .webma .m4a .wav]; end
        def mime_type_from_url(url)
          extension = Pathname.new(url).extname
          {
            '.ogg'     => 'application/ogg',
            '.ogx'     => 'application/ogg',
            '.ogv'     => 'video/ogg',
            '.oga'     => 'audio/ogg',
            '.mp4'     => 'video/mp4',
            '.m4v'     => 'video/mp4',
            '.mp3'     => 'audio/mpeg',
            '.m4a'     => 'audio/mpeg'
          }[extension] || ::MIME::Types.type_for(url).first
        end
      end


      def episode_source_urls_hash
        episode_source_urls.inject({}) do |hash, url|
          extension = Pathname.new(url).extname
          hash[extension] = url
          hash
        end
      end

      def source_extensions
        #episode_source_urls.map {|_| Pathname.new(_).extname }
        episode_source_urls_hash.keys
      end

     #def image_url
     #  episode_source_urls_hash.detect {|k,v| Podcast.image_extensions.include? k }
     #end
      def video_episode_source_urls_hash
        episode_source_urls_hash.select {|k,v| Podcast.video_extensions.include? k }
      end
      def audio_episode_source_urls_hash
        episode_source_urls_hash.select {|k,v| Podcast.audio_extensions.include? k }
      end
      def video_episode_source_urls
        video_episode_source_urls_hash.values
      end
      def audio_episode_source_urls
        audio_episode_source_urls_hash.values
      end

      def video?
        (source_extensions & Podcast.video_extensions).any?
      end

      def audio?
        (source_extensions & Podcast.audio_extensions).any?
      end

      # ugly workaround so that we can use best_in_place
      def source_0
        episode_source_urls[0]
      end
      def source_1
        episode_source_urls[1]
      end
      def source_0=(new)
        episode_source_urls[0] = new
        self.episode_source_urls = episode_source_urls.dup
      end
      def source_1=(new)
        episode_source_urls[1] = new
        self.episode_source_urls = episode_source_urls.dup
      end


      #---------------------------------------------------------------------------------------------

      after_initialize :initialize_publish_episodes_days_in_advance_of_date
      def initialize_publish_episodes_days_in_advance_of_date
        self.publish_episodes_days_in_advance_of_date = 0 if self.attributes['publish_episodes_days_in_advance_of_date'].nil?
      end

      def set_defaults
        self.title       = 'New Podcast'
        self.description = '<p>Description goes here</p>'
        self.episode_image_url   =  "http://example.com/{year}/{code}.png"
        self.episode_source_urls = ["http://example.com/{year}/{code}.m4a", "http://example.com/{year}/{code}.ogg"]
        self
      end

      def to_s
        title
      end

      #---------------------------------------------------------------------------------------------
    end
  end
end

