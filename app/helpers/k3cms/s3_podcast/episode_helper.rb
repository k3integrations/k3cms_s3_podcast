module K3cms::S3Podcast::EpisodeHelper
  def k3cms_s3_podcast_episode_thumbnail_image_url(episode)
    image_url = episode.image_url
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
    video_player episode.video_sources, {
      :poster => episode.image_url
    }.merge(Rails.application.config.k3cms_s3_podcast_video_tag_options)
  end

  def k3cms_s3_podcast_download_links(episode)
    episode.sources_hash.map { |extension, source_url|
      link_to(image_tag('k3cms/s3_podcast/video.png') + " #{t('Download')} #{extension} #{t('file')}", source_url)
    }.join('<br/>').html_safe
  end

  def k3cms_s3_podcast_audio_player(episode)
    audio_player episode.audio_sources
  end

  def video_player(sources, options = {})
    # FIXME: H.264 MP4 works in Firefox but not Chrome 10+
    options.merge!(:controls => 'true', :style => "display: block;")
    
    src_list=''; download_list=''; mp4_url=''
    #sources << 'http://video-js.zencoder.com/oceans-clip.ogv'
    sources.each do |source_url|
      case Pathname.new(source_url).extname
      when '.mp4', '.m4v'
        src_list += %Q(<source src="#{source_url}" type='video/mp4; codecs="avc1.42E01E, mp4a.40.2"' />\n)
        download_list += %Q(<a href="#{source_url}">MP4</a>\n)
        mp4_url = source_url
      when '.webm'
        src_list += %Q(<source src="#{source_url}" type='video/webm; codecs="vp8, vorbis"' />\n)
        download_list += %Q(<a href="#{source_url}">WEBM</a>\n)
      when '.ogv'
        src_list += %Q(<source src="#{source_url}" type='video/ogg; codecs="theora, vorbis"' />\n)
        download_list += %Q(<a href="#{source_url}">OGV</a>\n)
      end
    end
    raise "Must define at least one mp4 source: #{sources}" unless defined?(mp4_url)
    
    %Q(
      <div class="video-js-box">
        <!-- Using the Video for Everybody Embed Code http://camendesign.com/code/video_for_everybody -->
        <video class="video-js" width="#{options[:width]}" height="#{options[:height]}" controls preload poster="#{options[:poster]}">
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

        <!-- Download links provided for devices that can't play video in the browser. 
        <p class="vjs-no-video"><strong>Download Video:</strong>
          #{download_list}
        </p> -->

        <script type="text/javascript">
          $(function() {
            $('video.video-js').VideoJS();
          })
        </script>
      </div>
    ).html_safe
  end

  def audio_player(sources, options = {})
    #sources = ["http://www.jplayer.org/audio/m4a/Miaow-07-Bubble.m4a", "http://www.jplayer.org/audio/ogg/Miaow-07-Bubble.ogg"]

    sources_hash = {}
    sources.each do |source_url|
      extension = Pathname.new(source_url).extname
      extension = extension[1..-1] # drop leading '.'
      sources_hash[extension] = source_url
    end

    # http://www.jplayer.org/latest/quick-start-guide/step-8-audio/
    # "Note that for audio, you must supply either M4A or MP3 files to satisfy both HTML5 and Flash solutions."
    raise "Must define at least one m4a or mp3 source: #{sources}" unless (sources_hash.keys & ['m4a', 'mp3']).any?
    
    %Q(
      <div id="jquery_jplayer_1" class="jp-jplayer"></div>
      <div class="jp-audio">
        <div class="jp-type-single">
          <div id="jp_interface_1" class="jp-interface">
            <ul class="jp-controls">
              <li><a href="#" class="jp-play" tabindex="1">play</a></li>
              <li><a href="#" class="jp-pause" tabindex="1">pause</a></li>
              <li><a href="#" class="jp-stop" tabindex="1">stop</a></li>
              <li><a href="#" class="jp-mute" tabindex="1">mute</a></li>
              <li><a href="#" class="jp-unmute" tabindex="1">unmute</a></li>
            </ul>
            <div class="jp-progress">
              <div class="jp-seek-bar">
                <div class="jp-play-bar"></div>
              </div>
            </div>
            <div class="jp-volume-bar">
              <div class="jp-volume-bar-value"></div>
            </div>
            <div class="jp-current-time"></div>
            <div class="jp-duration"></div>
          </div>
          <div id="jp_playlist_1" class="jp-playlist">
            <!--
            <ul>
              <li>Title of media</li>
            </ul>
            -->
          </div>
        </div>
      </div>

      <script type="text/javascript">
        $(document).ready(function(){
          // Reference: http://www.jplayer.org/latest/developer-guide/#jPlayer-constructor
          //$("#jquery_jplayer_1")
          $(".jp-jplayer").jPlayer({
            ready: function () {
              $(this).jPlayer("setMedia", #{sources_hash.to_json}).
                      jPlayer("play"); // auto-start
            },
            supplied: "#{sources_hash.keys.join(', ')}",
            swfPath: "/k3cms/jquery.jplayer",
            solution: "html, flash",
            volume: 1,
          });
        });
      </script>
    ).html_safe
  end
end
