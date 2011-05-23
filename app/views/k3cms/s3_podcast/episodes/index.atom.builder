# References:
# * http://www.atomenabled.org/developers/syndication/
# * http://api.rubyonrails.org/classes/ActionView/Helpers/AtomFeedHelper.html
# * http://www.ibm.com/developerworks/xml/library/x-atom10.html

atom_feed(
  :language      => Rails.application.config.i18n.locale,
  :id            => k3cms_s3_podcast_podcast_episodes_url(@podcast),
  :root_url      => k3cms_s3_podcast_podcast_episodes_url(@podcast),
  'xmlns:itunes' => "http://www.itunes.com/dtds/podcast-1.0.dtd",
  'xmlns:media'  => "http://search.yahoo.com/mrss/",
) do |feed|

  # Required elements:
  feed.title       @podcast.title
  feed.updated     @episodes.first.try(:created_at) || Time.now

  # Optional elements:
  feed.icon        @podcast.icon_url                   if @podcast.icon_url.present?  # icon  Identifies a small image which provides iconic visual identification for the feed. Icons should be square.
  feed.tag! 'itunes:image', :href => @podcast.icon_url if @podcast.icon_url.present?
  feed.logo        @podcast.logo_url                   if @podcast.logo_url.present?  # logo  Identifies a larger image which provides visual identification for the feed. Images should be twice as wide as they are tall.
  feed.rights      @podcast.rights, :type => 'html'    if @podcast.rights.present?
  feed.generator  'K3cms (http://k3cms.k3integrations.com)'
 #feed.author
 #feed.category
 #feed.contributor
 #feed.subtitle

  @episodes.each do |episode|
    feed.entry episode do |entry|
      entry.title episode.title
      episode.source_urls.each do |url|
        entry.link :rel => 'enclosure', :href => url, :type => K3cms::S3Podcast::Podcast::mime_type_from_url(url)
      end
      entry.summary episode.description, :type => 'html'
      entry.author do |author|
        author.name episode.author_name
      end
      episode.tags.each do |tag|
        entry.category :term => tag
      end

      # http://video.search.yahoo.com/mrss
      feed.tag! 'media:thumbnail', :url => episode.image_url

     #entry.contributor
     #entry.rights
    end
  end
end
