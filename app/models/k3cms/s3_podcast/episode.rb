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

      def set_defaults
        self.title   = 'New Episode'                          if self.attributes['title'].nil?
        self.description = '<p>Description goes here</p>'     if self.attributes['description'].nil?
        self.display_date = Date.tomorrow                     if self.attributes['display_date'].nil?
        self
      end

      def to_s
        title
      end

      def scrubbed_title
        title.gsub(/\s+/,'_').gsub(/[^a-zA-Z0-9_-]/,'')
      end
      
      def thumbnail_image_url
        replace_vars :thumbnail_image_url
      end

      # Question: When would this be different than download_url?
      def view_url
        replace_vars :view_url
      end
      
      def download_url
        replace_vars :download_url
      end

      def published?
        display_date and Time.zone.now >= display_date.beginning_of_day
      end

      def as_json(options={})
        super(
          :methods => [
            :published?,
            :thumbnail_image_url,
            :view_url,
            :download_url,
          ]
        )
      end
      
    private
      
      def replace_vars(name)
        url = Rails.application.config.k3cms_s3_podcast_asset_urls[name].dup
        return '' if code.blank?
        url.gsub!(/\{\s*CODE\s*\}/i, code)
        url.gsub!(/\{\s*YEAR\s*\}/i, display_date.year.to_s)
        url.gsub(/\{\s*TITLE\s*\}/i, scrubbed_title)
      end

    end
  end
end
