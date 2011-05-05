module K3cms
  module S3Podcast
    class Episode < ActiveRecord::Base
      set_table_name 'k3cms_s3_podcast_episodes'

      belongs_to :author, :class_name => 'User'
      belongs_to :podcast

      acts_as_taggable

      #scope :published,    lambda { where(['display_date <= ? - interval k3cms_s3_podcast.publish_days_in_advance_of_episode_date day', Time.now.to_date]) }
      scope :published,    lambda { where(['display_date <= ?', Time.now.to_date]) }

      scope :most_recent,  lambda { published.order('display_date DESC') }
      scope :most_popular, lambda { published.order('view_count DESC') }
      scope :random,       order('rand() ASC')

      #paginates_per Rails.application.config.k3cms_s3_podcast_pagination[:per_page]

      normalize_attributes :title, :description, :with => [:strip, :blank]

      validates :title, :presence => true
      validates :podcast, :presence => true
      validates :code, :presence => true, :uniqueness => {:scope => :podcast_id}
      validates :display_date, :timeliness => {:type => :date}

      #---------------------------------------------------------------------------------------------
      # Sources

      delegate :image?, :video?, :audio?, :to => :podcast

      def sources
        podcast.sources.map { |url| get_url(url) }
      end

      def sources_hash
        sources.inject({}) do |hash, source_url|
          extension = Pathname.new(source_url).extname
          hash[extension] = source_url
          hash
        end
      end

      def image_url
        #sources_hash.detect {|k,v| Podcast.image_extensions.include? k }
        get_url(podcast.image_url)
      end
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

      #---------------------------------------------------------------------------------------------

      def set_defaults
        self.title   = 'New Episode'                          if self.attributes['title'].nil?
        self.description = '<p>Description goes here</p>'     if self.attributes['description'].nil?
        self.display_date = Date.tomorrow                     if self.attributes['display_date'].nil?
        self
      end

      def published?
        display_date and Time.zone.now >= display_date.beginning_of_day
      end

      #---------------------------------------------------------------------------------------------
      # Conversions

      def as_json(options={})
        super(
          :methods => [
            :published?,
            :image_url,
            :video_sources,
            :audio_sources,
          ]
        )
      end

      def to_s
        title
      end

      #---------------------------------------------------------------------------------------------

      
    private
      
      def get_url(url)
        return '' if url.blank?
        url.dup.tap do |url|
          url.gsub!(/\{code\}/i,  code)
          url.gsub!(/\{year}/i,   display_date.try(:year).to_s)
          url.gsub!(/\{month}/i,  display_date.try(:strftime, '%m').to_s)
          url.gsub!(/\{day}/i,    display_date.try(:strftime, '%d').to_s)
          url.gsub!(/\{title\}/i, url_friendly_title.to_s)
        end
      end

      def url_friendly_title
        title.present? && title.gsub(/\s+/,'_').gsub(/[^a-zA-Z0-9_-]/,'')
      end

    end
  end
end
