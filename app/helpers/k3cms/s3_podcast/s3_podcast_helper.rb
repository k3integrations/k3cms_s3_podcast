module K3cms::S3Podcast::S3PodcastHelper
  def k3cms_s3_podcast_episode_thumbnail_image_url(episode)
    image_url = episode.thumbnail_image_url
    options = {:width => 166, :height => 125}
    if image_url.blank?
      image_url = 'k3cms/s3_podcast/transparent_1x1.png'
      options.merge! :style => 'border: 1px solid gray'
      # TODO: overlay text "Click to Choose image/video"
    end
    image_tag(image_url, options)
  end

  def k3cms_s3_podcast_episode_classes(episode)
    [
      dom_class(episode),
      dom_id(episode),
      ('new_record' if episode.new_record?),
      (episode.published? ? 'published' : 'unpublished'),
    ].compact
  end

  def k3cms_s3_podcast_episode_linked_tag_list(episode)
    episode.tag_list.map { |tag_name| link_to(tag_name, k3cms_s3_podcast_episodes_path(:tag_list => tag_name)) }.join(', ').html_safe
  end

  def k3cms_s3_podcast_video_player(episode)
    video_player [episode.view_url], {
      :poster => episode.thumbnail_image_url
    }.merge(Rails.application.config.k3cms_s3_podcast_video_tag_options)
  end

  def video_player(sources, options = {})
    # FIXME: H.264 MP4 works in Firefox but not Chrome 10+
    options.merge!(:controls => 'true', :style => "display: block;")
    content_tag(:video, options, false) do
      sources.map do |source_url|
        case source_url
        when /mp4$/, /m4v$/
          type = "video/h264"
        when /ogv/
          type = "video/ogg"
        end
        content_tag(:source, '', :src => source_url, :type => type)
      end.join("\n").html_safe
    end
  end
end
