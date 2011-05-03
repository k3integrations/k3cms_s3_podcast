module K3cms::S3Podcast::EpisodeHelper
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
      (episode.published? ? 'published' : 'unpublished'),
      (episode.new_record? ? 'new_record' : 'visible'),
    ].compact
  end

  def k3cms_s3_podcast_episode_linked_tag_list(episode)
    episode.tag_list.map { |tag_name| 
      link_to(tag_name, k3cms_s3_podcast_podcast_episodes_path(episode.podcast, :tag_list => tag_name))
    }.join(', ').html_safe
  end

  def k3cms_s3_podcast_video_player(episode)
    video_player [episode.view_url], {
      :poster => episode.thumbnail_image_url
    }.merge(Rails.application.config.k3cms_s3_podcast_video_tag_options)
  end

  def video_player(sources, options = {})
    # FIXME: H.264 MP4 works in Firefox but not Chrome 10+
    options.merge!(:controls => 'true', :style => "display: block;")
    
    src_list=''; download_list=''; mp4_url=''
    sources.each do |source_url|
      case source_url
      when /mp4$/, /m4v$/
        src_list += %Q(<source src="#{source_url}" type='video/mp4; codecs="avc1.42E01E, mp4a.40.2"' />\n)
        download_list += %Q(<a href="#{source_url}" />MP4</a>\n)
        mp4_url = source_url
      when /webm$/
        src_list += %Q(<source src="#{source_url}" type='video/webm; codecs="vp8, vorbis"' />\n)
        download_list += %Q(<a href="#{source_url}" />WEBM</a>\n)
      when /ogv$/
        src_list += %Q(<source src="#{source_url}" type='video/ogg; codecs="theora, vorbis"' />\n)
        download_list += %Q(<a href="#{source_url}" />OGV</a>\n)
      end
    end
    raise "Must define at least one mp4 file: #{sources}" unless defined?(mp4_url)
    
    %Q(
      <div class="video-js-box">
        <!-- Using the Video for Everybody Embed Code http://camendesign.com/code/video_for_everybody -->
        <video class="video-js" width="#{options[:width]}" height=":#{options[:height]}" controls preload poster="#{options[:poster]}">
          #{src_list}
          <!-- Flash Fallback. Use any flash video player here. Make sure to keep the vjs-flash-fallback class. -->
          <object class="vjs-flash-fallback" width="#{options[:width]}" height="#{options[:height]}" type="application/x-shockwave-flash"
            data="http://releases.flowplayer.org/swf/flowplayer-3.2.1.swf">
            <param name="movie" value="http://releases.flowplayer.org/swf/flowplayer-3.2.1.swf" />
            <param name="allowfullscreen" value="true" />
            <param name="flashvars" value='config={"playlist":["#{options[:poster]}", {"url": "#{mp4_url}","autoPlay":false,"autoBuffering":true}]}' />
            <!-- Image Fallback. Typically the same as the poster image. -->
            <img src="#{options[:poster]}" width="#{options[:width]}" height="#{options[:height]}" alt="Poster Image"
              title="No video playback capabilities." />
          </object>
        </video>
        <!-- Download links provided for devices that can't play video in the browser. -->
        <p class="vjs-no-video"><strong>Download Video:</strong>
          #{download_list}
          <!-- Support VideoJS by keeping this link. -->
          <a href="http://videojs.com">HTML5 Video Player</a> by VideoJS
        </p>
      </div>).html_safe
  end
end
