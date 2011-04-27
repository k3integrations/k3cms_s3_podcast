require 'spec_helper'

module K3cms::S3Podcast
  describe EpisodesController do

    let(:user) { mock_model(User, :k3cms_permitted? => true) }
    before { controller.stub :current_user => user }

    #let(:mock_episode) { mock_model(Episode) }
    def mock_episode(stubs={})
      (@mock_episode ||= mock_model(Episode).as_null_object).tap do |episode|
        episode.stub(stubs) unless stubs.empty?
      end
    end

    it "should understand routes" do
      assert_routing "/episodes",            {:controller=>"k3cms/s3_podcast/episodes", :action=>"index", }
      # TODO: figure out how to make these pass
     #assert_routing "/episodes/1",          {:controller=>"k3cms/s3_podcast/episodes", :action=>"show",  :id => 1}
     #assert_routing "/podcasts/1/episodes", {:controller=>"k3cms/s3_podcast/episodes", :action=>"index", :k3cms_s3_podcast_podcasts => 1}
    end

    before do
      @podcast = Podcast.make
      @episode = @podcast.episodes.make
    end

    describe "#index" do
     #context "not nested" do
     #  it "assigns all episodes as @episodes" do
     #    get :index
     #    assigns(:episodes).size.should == 1
     #    assigns(:episodes).should == [@episode]
     #  end
     #end

      context "nested" do
        it "assigns all episodes for podcast as @episodes" do
          get :index, :podcast_id => @podcast
          assigns(:episodes).size.should == 1
          assigns(:episodes).should == [@episode]
        end
      end
    end

    describe "#show" do
      context "not nested" do
        it "assigns the requested episode as @episode" do
          Episode.stub(:find).with("37") { mock_episode }
          get :show, :id => "37"
          assigns(:episode).should be(mock_episode)
        end
      end
    end

    describe "#new" do
      context "not nested" do
        it "assigns a new episode as @episode" do
          Episode.stub(:new) { mock_episode }
          get :new
          assigns(:episode).should be(mock_episode)
        end
      end

      context "nested" do
        it "assigns a new episode as @episode" do
          get :new, :podcast_id => @podcast
          assigns(:episode).should be_instance_of(Episode)
          assigns(:podcast).should == @podcast
          #puts "assigns=#{assigns.keys.inspect}"
        end
      end
    end

#    describe "#edit" do
#      it "assigns the requested episode as @episode" do
#        Episode.stub(:find).with("37") { mock_episode }
#        get :edit, :id => "37"
#        assigns(:episode).should be(mock_episode)
#      end
#    end
#
#    describe "#create" do
#
#      describe "with valid params" do
#        it "assigns a newly created episode as @episode" do
#          Episode.stub(:new).with({'these' => 'params'}) { mock_episode(:save => true) }
#          post :create, :k3cms_episode => {'these' => 'params'}
#          assigns(:episode).should be(mock_episode)
#        end
#
#        it "redirects to the created episode" do
#          Episode.stub(:new) { mock_episode(:save => true) }
#          post :create, :k3cms_episode => {}
#          response.should redirect_to(k3cms_episode_url(mock_episode))
#        end
#      end
#
#      describe "with invalid params" do
#        it "assigns a newly created but unsaved episode as @episode" do
#          Episode.stub(:new).with({'these' => 'params'}) { mock_episode(:save => false) }
#          post :create, :k3cms_episode => {'these' => 'params'}
#          assigns(:episode).should be(mock_episode)
#        end
#
#        it "re-renders the 'new' template" do
#          Episode.stub(:new) { mock_episode(:save => false) }
#          post :create, :k3cms_episode => {}
#          response.should render_template("new")
#        end
#      end
#
#    end
#
#    describe "#update" do
#
#      describe "with valid params" do
#        it "updates the requested episode" do
#          Episode.should_receive(:find).with("37") { mock_episode }
#          mock_episode.should_receive(:update_attributes).with({'these' => 'params'})
#          put :update, :id => "37", :k3cms_episode => {'these' => 'params'}
#        end
#
#        it "assigns the requested episode as @episode" do
#          Episode.stub(:find) { mock_episode(:update_attributes => true) }
#          put :update, :id => "1"
#          assigns(:episode).should be(mock_episode)
#        end
#
#        it "redirects to the episode" do
#          Episode.stub(:find) { mock_episode(:update_attributes => true) }
#          put :update, :id => "1"
#          response.should redirect_to(k3cms_episode_url(mock_episode))
#        end
#      end
#
#      describe "with invalid params" do
#        it "assigns the episode as @episode" do
#          Episode.stub(:find) { mock_episode(:update_attributes => false) }
#          put :update, :id => "1"
#          assigns(:episode).should be(mock_episode)
#        end
#
#        it "re-renders the 'edit' template" do
#          Episode.stub(:find) { mock_episode(:update_attributes => false) }
#          put :update, :id => "1"
#          response.should render_template("edit")
#        end
#      end
#
#    end
#
#    describe "DELETE destroy" do
#      it "destroys the requested episode" do
#        Episode.should_receive(:find).with("37") { mock_episode }
#        mock_episode.should_receive(:destroy)
#        delete :destroy, :id => "37"
#      end
#
#      it "redirects to the episodes list" do
#        Episode.stub(:find) { mock_episode }
#        delete :destroy, :id => "1"
#        response.should redirect_to(k3cms_podcast_episodes_url(@podcast))
#      end
#    end

  end
end
