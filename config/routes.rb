Rails.application.routes.draw do
  resources :k3cms_s3_podcast_episodes, :path => 'episodes', :controller => 'k3cms/s3_podcast/episodes'
  resources :k3cms_s3_podcast_podcasts, :path => 'podcasts', :controller => 'k3cms/s3_podcast/podcasts' do
    resources :episodes, :controller => 'k3cms/s3_podcast/episodes'
  end
end
