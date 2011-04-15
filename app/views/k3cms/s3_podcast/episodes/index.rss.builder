config = Rails.application.config
xml.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8"
xml.rss('xmlns:itunes' => 'http://www.itunes.com/dtds/podcast-1.0.dtd', 'xmlns:atom' => 'http://www.w3.org/2005/Atom', 'version' => '2.0') do
  xml.channel do
    xml.title(config.k3cms_s3_podcast_title)
    xml.link( config.k3cms_s3_podcast_link_url)
    xml.atom(:link, :href => config.k3cms_s3_podcast_podcast_url, :rel => 'self', :type => 'application/rss+xml')
    xml.description(config.k3cms_s3_podcast_description)
    xml.itunes(:summary, config.k3cms_s3_podcast_summary)
    xml.itunes(:explicit, 'no')
    xml.itunes(:category, :text => config.k3cms_s3_podcast_category) do
      #xml.itunes(:category, :text => '...')
    end
    xml.language("en-us")
    #xml.itunes(:image, :href => '')

    @episodes.each do |episode|
      xml.item do
        xml.title(episode.title)
        xml.itunes(:summary, episode.description)
        xml.description(episode.description)
        #xml.itunes(:author,episode.presenter) unless episode.presenter.blank?
        xml.pubDate(episode.published_at.to_datetime.to_s(:rfc822))
        xml.enclosure(:url => episode.download_url, :type => 'video/mp4')
        xml.guid({:isPermaLink => "false"}, k3cms_s3_podcast_episode_url(episode))
        xml.itunes(:keywords, episode.tag_list) unless episode.tag_list.blank?
      end
    end
  end
end
