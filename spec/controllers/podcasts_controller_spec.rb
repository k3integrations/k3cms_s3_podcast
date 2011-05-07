require 'spec_helper'

module K3cms::S3Podcast
  describe PodcastsController do

    # Fix for "undefined method `authenticate' for nil:NilClass" in k3cms_user
    let(:user) { mock_model(User, :k3cms_permitted? => true) }
    before { controller.stub :current_user => user }


    it "should understand routes" do
      assert_routing "/podcasts",            {:controller=>"k3cms/s3_podcast/podcasts", :action=>"index", }
    end

    before do
      @video_podcast = Podcast.make(:video)
      @audio_podcast = Podcast.make(:audio)
    end

    it "our fixtures are what we expect" do
      @audio_podcast.should be_audio
      @video_podcast.should be_video
    end

    describe "#index" do
      context "not nested" do
        it "assigns all podcasts as @podcasts" do
          get :index
          assigns(:podcasts).should == [@video_podcast, @audio_podcast]
        end
      end
    end

    pending "it has complete spec coverage"
  end
end
