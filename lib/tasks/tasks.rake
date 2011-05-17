namespace :k3cms do
  namespace :s3_podcast do
    desc "Install K3cms S3Podcast"
    task :install => [:copy_public, :copy_migrations] do
      puts "Don't forget to run:
rails generate k3cms_s3_podcast_initializer"
    end
    
    desc "Copy public files"
    task :copy_public do
      K3cms::FileUtils.copy_or_symlink_files_from_gem K3cms::S3Podcast, 'public/**/*'
    end
    
    desc "Copy migrations"
    task :copy_migrations do
      K3cms::FileUtils.copy_from_gem K3cms::S3Podcast, 'db/migrate'
    end
  end
end
