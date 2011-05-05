class UriValidator < ActiveModel::EachValidator
  def validate_each(object, attribute, value)
    configuration = { :message => "is invalid", :format => URI::regexp(%w(http https)) }
    configuration.update(options)
    
    unless value =~ configuration[:format]
      object.errors.add(attribute, configuration[:message])
    end
  end
end

module K3cms
  module S3Podcast
    class Podcast < ActiveRecord::Base
      set_table_name 'k3cms_s3_podcast_podcasts'

      has_many :episodes, :class_name => 'K3cms::S3Podcast::Episode'
      belongs_to :author, :class_name => 'User'

      normalize_attributes :title, :summary, :description, :with => [:strip, :blank]

      validates :title, :presence => true

      validates :image_url, :presence => true, :uri => true

      #---------------------------------------------------------------------------------------------
      # Sources

      serialize :sources
      normalize_attributes :sources, :with => [:reject_blank]

      after_initialize :initialize_sources
      def initialize_sources
        self.sources ||= []
      end

      validate :validate_sources
      def validate_sources
        sources.any? or errors[:sources] << "must include one source"
        # TODO: use UriValidator
      end

      class << self
        def image_extensions; %w[.png .jpg .gif]; end
        def video_extensions; %w[.mp4 .ogv .webmv .m4v]; end
        def audio_extensions; %w[.mp3 .oga .webma .m4a .wav]; end
      end

      def sources_hash
        sources.inject({}) do |hash, url|
          extension = Pathname.new(url).extname
          hash[extension] = url
          hash
        end
      end

      def source_extensions
        #sources.map {|_| Pathname.new(_).extname }
        sources_hash.keys
      end

     #def image_url
     #  sources_hash.detect {|k,v| Podcast.image_extensions.include? k }
     #end
      def video_sources_hash
        sources_hash.select {|k,v| Podcast.video_extensions.include? k }
      end
      def audio_sources_hash
        sources_hash.select {|k,v| Podcast.audio_extensions.include? k }
      end
      def video_sources
        video_sources_hash.values
      end
      def audio_sources
        audio_sources_hash.values
      end

     #def image?
     #  (source_extensions & Podcast.image_extensions).any?
     #end

      def video?
        (source_extensions & Podcast.video_extensions).any?
      end

      def audio?
        (source_extensions & Podcast.audio_extensions).any?
      end

      # ugly workaround so that we can use best_in_place
      def source_0
        sources[0]
      end
      def source_1
        sources[1]
      end
      def source_0=(new)
        sources[0] = new
        self.sources = sources.dup
      end
      def source_1=(new)
        sources[1] = new
        self.sources = sources.dup
      end


      #---------------------------------------------------------------------------------------------
      def set_defaults
        self.title       = 'New Podcast'
        self.description = '<p>Description goes here</p>'
        self.image_url   =  "http://example.com/{year}/{code}.png"
        self.sources     = ["http://example.com/{year}/{code}.m4a", "http://example.com/{year}/{code}.ogg"]
        self.publish_days_in_advance_of_display_date = 0
        self
      end

      def to_s
        title
      end

      #---------------------------------------------------------------------------------------------
    end
  end
end

