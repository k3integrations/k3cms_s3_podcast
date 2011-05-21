module K3cms
  module S3Podcast
    class Episode < ActiveRecord::Base
      set_table_name 'k3cms_s3_podcast_episodes'

      belongs_to :author, :class_name => 'User'
      belongs_to :podcast

      acts_as_taggable

      scope :most_recent,  lambda { order('date DESC') }
      scope :most_popular, lambda { order('view_count DESC') }
      scope :random,       order('rand() ASC')
      scope :without,      lambda {|obj| where(['id != ?', obj.is_a?(Integer) ? obj : obj.id]) }

      def related
        tag_list.blank? ? Episode.where('null') : Episode.tagged_with(tag_list, :any => :true).without(id)
      end

      paginates_per Rails.application.config.k3cms.s3_podcast.pagination[:per_page]

      normalize_attributes :title, :description, :code, :with => [:strip, :blank]

      validates :code, :presence => true, :if => :code_is_required?
      validates :title, :presence => true
      validates :podcast, :presence => true
      validates :code, :uniqueness => {:scope => :podcast_id}, :allow_nil => true
      validates :date, :timeliness => {:type => :date}

      #---------------------------------------------------------------------------------------------

      # FIXME: This is currently MySQL specific. I tried to do it in Arel, like so:
      #   K3cms::S3Podcast::Episode.joins(:podcast).where(
      #     (Episode.arel_table[:date] - Podcast.arel_table[:publish_episodes_days_in_advance_of_date]) < Date.today
      #   )
      # but got this error:
      #   NoMethodError: undefined method `-' for #<Arel::Attributes::Time:0x00000004bb6148>
      # Is something like that possible without using raw SQL??
      scope :published, lambda {
        joins(:podcast).
        where([':today >= k3cms_s3_podcast_episodes.date
                   - interval k3cms_s3_podcast_podcasts.publish_episodes_days_in_advance_of_date day',
               {:today => Time.zone.now.to_date}])
      }

      def published?
        date and Time.zone.now >= date.beginning_of_day - podcast.publish_episodes_days_in_advance_of_date.days
      end
      def unpublished?
        !published?
      end

      #---------------------------------------------------------------------------------------------
      # Sources

      delegate :image?, :video?, :audio?, :to => :podcast
      def code_is_required?
        # can't use delegate because podcast not present for new records
        podcast && podcast.code_is_required?
      end

      def source_urls
        podcast.episode_source_urls.map { |url| get_url(url) }
      end

      def source_urls_hash
        source_urls.inject({}) do |hash, source_url|
          extension = Pathname.new(source_url).extname
          hash[extension] = source_url
          hash
        end
      end

      def image_url
        #source_urls_hash.detect {|k,v| Podcast.image_extensions.include? k }
        get_url(podcast.episode_image_url)
      end
      def video_source_urls_hash
        source_urls_hash.select {|k,v| Podcast.video_extensions.include? k }
      end
      def audio_source_urls_hash
        source_urls_hash.select {|k,v| Podcast.audio_extensions.include? k }
      end
      def video_source_urls
        video_source_urls_hash.values
      end
      def audio_source_urls
        audio_source_urls_hash.values
      end

      #---------------------------------------------------------------------------------------------

      def set_defaults
        self.title   = 'New Episode'                          if self.attributes['title'].nil?
        self.description = '<p>Description goes here</p>'     if self.attributes['description'].nil?
        self.date = Date.tomorrow                     if self.attributes['date'].nil?
        self
      end

      #---------------------------------------------------------------------------------------------
      # Conversions

      def as_json(options={})
        super(
          :methods => [
            :published?,
            :image_url,
            :video_source_urls,
            :audio_source_urls,
          ]
        )
      end

      def to_s
        title
      end

      #---------------------------------------------------------------------------------------------

      
    private

      class MissingParamForInterpolation < Exception
      end
      
      def get_url(url)
        return nil if url.blank?
        begin
          url.dup.tap do |url|
            url.gsub!(/\{code\}/i) { code || raise(MissingParamForInterpolation) }
            url.gsub!(/\{year}/i,   date.try(:year).to_s)
            url.gsub!(/\{month}/i,  date.try(:strftime, '%m').to_s)
            url.gsub!(/\{day}/i,    date.try(:strftime, '%d').to_s)
            url.gsub!(/\{title\}/i, url_friendly_title.to_s)
          end
        rescue MissingParamForInterpolation
          nil
        end
      end

      def url_friendly_title
        title.present? && title.gsub(/\s+/,'_').gsub(/[^a-zA-Z0-9_-]/,'')
      end

    end
  end
end
