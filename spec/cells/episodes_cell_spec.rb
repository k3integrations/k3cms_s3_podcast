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
      output.should have_tag('div.context_ribbon') do |ribbon|
        ribbon.should have_tag('input[type=hidden][name="k3cms_s3_podcast_episode[podcast_id]"]')
        ribbon.should have_tag(".editable[data-attribute='code']")
        ribbon.should have_tag(".editable[data-attribute='date']")
      end
    end

    context "cell instance" do
      subject { cell('k3cms/s3_podcast/episodes') }
      it { should respond_to(:published_status) }
      it { should respond_to(:context_ribbon) }
      it { should respond_to(:record_js) }
    end
  end
end
