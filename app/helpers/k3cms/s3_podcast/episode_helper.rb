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
      'k3cms_s3_podcast',
      dom_class(episode),
      dom_id(episode),
      (episode.published? ? 'published' : 'unpublished'),
      (episode.new_record? ? 'new_record' : 'record_exists'),
    ].compact
  end

  def k3cms_s3_podcast_episode_linked_tag_list(episode)
    episode.tag_list.map { |tag_name| 
      link_to(tag_name, k3cms_s3_podcast_podcast_episodes_path(episode.podcast, :tag_list => tag_name))
    }.join(', ').html_safe
  end

  def k3cms_s3_podcast_episode_player(episode, options = {})
    (k3cms_s3_podcast_video_player(episode, options) if episode.podcast.video?).to_s.html_safe +
    (k3cms_s3_podcast_audio_player(episode, options) if episode.podcast.audio?).to_s.html_safe
  end

  def k3cms_s3_podcast_video_player(episode, options = {})
    video_player(episode.video_source_urls,
      {
        :poster => episode.image_url
      }.merge(Rails.application.config.k3cms.s3_podcast.video_tag_options).
        merge(options)
    )
  end

  def k3cms_s3_podcast_audio_player(episode, options = {})
    audio_player episode.audio_source_urls, options
  end

  def k3cms_s3_podcast_download_links(episode)
    episode.source_urls_hash.map { |extension, source_url|
      link_to(image_tag('k3cms/s3_podcast/video.png') + " " + t('Download {extension} file', :extension => extension), source_url, :class => 'download with_icon')
    }.join('<br/>').html_safe
  end

  def video_player(source_urls, options = {})
    options.reverse_merge!(
        :controls => 'true',
        :style => "display: block;",
        :autoplay => false,
    )

    src_list=''
    source_urls.each do |source_url|
      case Pathname.new(source_url).extname
      when '.mp4', '.m4v'
        src_list += %Q(<source src="#{source_url}" type="video/mp4" />\n)
      when '.webm'
        src_list += %Q(<source src="#{source_url}" type="video/webm" />\n)
      when '.wmv'
        src_list += %Q(<source src="#{source_url}" type="video/x-ms-wmv" />\n)
      end
    end

    # "Note that for video, you must supply at least an M4V"
    raise "Must define at least one m4v source: #{source_urls}" unless src_list.include?('video/mp4')

    %Q(
      <div class="player">
        <video>
          #{src_list}
        </video>
      </div>

      <script type="text/javascript">
        $(function() {
          $(".player").flowplayer({ swf: "/k3cms/flowplayer.swf" });
        });
      </script>
    ).html_safe
  end

  def audio_player(source_urls, options = {})
    #source_urls = ["http://www.jplayer.org/audio/m4a/Miaow-07-Bubble.m4a", "http://www.jplayer.org/audio/ogg/Miaow-07-Bubble.ogg"]

    source_urls_hash = {}
    source_urls.each do |source_url|
      extension = Pathname.new(source_url).extname
      extension = extension[1..-1] # drop leading '.'
      source_urls_hash[extension] = source_url
    end

    # http://www.jplayer.org/latest/quick-start-guide/step-8-audio/
    # "Note that for audio, you must supply either M4A or MP3 files to satisfy both HTML5 and Flash solutions."
    raise "Must define at least one m4a or mp3 source: #{source_urls}" unless (source_urls_hash.keys & ['m4a', 'mp3']).any?
    
    %Q(
      <div id="jquery_jplayer_1" class="jp-jplayer"></div>
      <div class="player audio_player jp-audio">
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
              $(this).jPlayer('setMedia', #{source_urls_hash.to_json});
              #{if options[:autoplay]
             "$(this).jPlayer('play');"
              end}
            },
            supplied: "#{source_urls_hash.keys.join(', ')}",
            swfPath: "/k3cms/jquery.jplayer",
            solution: "html, flash",
            volume: 1
          });
        });
      </script>
    ).html_safe
  end
end
