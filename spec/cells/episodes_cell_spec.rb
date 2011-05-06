require 'spec_helper'

module K3cms::S3Podcast
  describe PodcastsCell do
    let(:user) { mock_model(User, :k3cms_permitted? => true) }
    before do
      controller.stub :k3cms_user => user
      controller.session[:edit_mode] = true
    end

    let(:episode) { Episode.make }

    it "renders something" do
      output = render_cell('k3cms/s3_podcast/episodes', :context_ribbon, :episode => episode)
      output.should have_selector('div.context_ribbon') do |ribbon|
        ribbon.should have_selector("input[type=hiddon]k3cms_s3_podcast_episode[podcast_id]") 
        ribbon.should have_selector(".editable[data-attribute='code']") 
        ribbon.should have_selector(".editable[data-attribute='date']") 
      end
    end

    context "cell instance" do 
      subject { cell('k3cms/s3_podcast/episodes') } 
      it { should respond_to(:published_status) }
      it { should respond_to(:context_ribbon) }
      it { should respond_to(:record_editing_js) }
    end
  end
end


#describe EpisodesCell do
#  context "cell rendering" do 
#    
#    context "rendering show" do
#      subject { render_cell(:episodes, :show) }
#  
#      it { should have_selector("h1", :content => "Episodes#show") }
#      it { should have_selector("p", :content => "Find me in app/cells/episodes/show.html") }
#    end
#    
#  end
#end
