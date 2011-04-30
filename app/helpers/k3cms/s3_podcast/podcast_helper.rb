module K3cms::S3Podcast::PodcastHelper
  def k3cms_s3_podcast_podcast_classes(podcast)
    [
      dom_class(podcast),
      dom_id(podcast),
      (podcast.new_record? ? 'new_record' : 'visible'),
    ].compact
  end
end
