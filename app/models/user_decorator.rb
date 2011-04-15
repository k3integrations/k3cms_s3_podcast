User.class_eval do
  has_many :k3cms_s3_podcast_episodes, :class_name => 'K3cms::S3Podcast::Episode', :foreign_key => 'author_id'
end
