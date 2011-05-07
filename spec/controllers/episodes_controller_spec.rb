require 'spec_helper'

module K3cms::S3Podcast
  describe EpisodesController do

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
      @unpublished_episode = @podcast.episodes.make(:unpublished)
      @episode   =           @podcast.episodes.make
    end

    it "our fixtures are what we expect" do
      @unpublished_episode.should_not be_published
      @episode.            should     be_published
    end

    # Fix for "undefined method `authenticate' for nil:NilClass" in k3cms_user
    before { controller.stub :current_user => user }

    def real_user
      #puts "@real_user=#{@real_user.inspect}"
      @real_user ||= User.first || User.make
    end
    def guest_user
      #puts "@guest_user=#{@guest_user.inspect}"
      @guest_user ||= K3cms::Authorization::GuestUser.new
    end
    let(:user) { guest_user }


    describe "#index" do
     #context "not nested" do
     #  it "assigns all episodes as @episodes" do
     #    get :index
     #    assigns(:episodes).size.should == 1
     #    assigns(:episodes).should == [@episode]
     #  end
     #end

      context "nested" do
        before do
          get :index, :podcast_id => @podcast
        end

        # TODO?: Actually EpisodesIndexCell is where it filters out the unpublished episodes -- add a test there
        it "does not include unpublished episodes" do
          assigns(:episodes).should_not include(@unpublished_episode)
        end

        context "logged in as user with all permissions" do
          let(:user) { real_user }

          it "*does* include unpublished episodes" do
            pending
            assigns(:episodes).should include(@unpublished_episode)
          end
        end

        it "assigns all episodes for podcast as @episodes" do
          assigns(:episodes).should == [@episode]
        end
      end
    end

    describe "#index.atom" do
      render_views

      context "nested" do
        before do
          get :index, :podcast_id => @podcast, :format => 'atom'
        end

        it "does not include unpublished episodes" do
          assigns(:episodes).should_not include(@unpublished_episode)
        end

        context "logged in as user with all permissions" do
          let(:user) { real_user }

          it "still does not include unpublished episodes" do
            assigns(:episodes).should_not include(@unpublished_episode)
          end
        end

        it "assigns all episodes for podcast as @episodes" do
          #puts "assigns=#{assigns.keys.inspect}"
          assigns(:episodes).should == [@episode]
          #puts "assigns(:episodes)=#{assigns(:episodes).inspect}"
          response.should render_template("index")
          #puts "response=#{response.inspect}"
          #puts "response=#{response.body}"
        end

        it "should look like a feed" do
          response.body.should have_tag('feed')
        end
      end

      context "when there are no episodes" do
        before do
          Episode.delete_all
          get :index, :podcast_id => @podcast, :format => 'atom'
        end

        it "should not blow up" do
          response.should render_template("index")
          response.should be_success
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

#  end # context "logged in as user with no permissions"
#
#    context "logged in as user with all permissions" do
#      let(:user) { mock_model(User, :k3cms_permitted? => true) }
#
#    end # context "logged in as user with all permissions"

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

    pending "it has complete spec coverage"
  end
end
