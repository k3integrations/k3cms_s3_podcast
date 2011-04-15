Rails.application.routes.draw do
  resources :k3cms_s3_podcast_episodes, :path => 'episodes', :controller => 'k3cms/s3_podcast/episodes'
end
