class K3cmsS3PodcastInitializerGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)

  def copy_initializer_file
    template "initializer.rb.erb", "config/initializers/k3cms_s3_podcast.rb"
  end
end
