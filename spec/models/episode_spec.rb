# encoding: utf-8
require 'spec_helper'
require 'app/models/k3cms/s3_podcast/episode'

module K3cms::S3Podcast
  describe Episode do
    before do
      Time.stub!(:now).and_return(Time.mktime(2011,1,1, 12,0))
    end

    describe "when a new record is initialized" do
      before do

        @episode = Episode.new
      end

      it "should have summary set to #{s='<p>Summary description goes here</p>'}" do
        @episode.summary.should == s
      end
      it "should have body set to nil" do
        @episode.body.should == nil
      end
      it "should have date set to tomorrow" do
        @episode.date.should == Date.new(2011,1,2)
      end
    end

    describe "when a saved record (with body set to nil) is initialized" do
      before do
        @episode = Episode.create!(:title => 'Something')
        @episode.update_attributes!(:body => nil)
      end

      it "should not change body" do
        @episode.body.should be_nil
      end
    end

    describe "when a new record is initialized with summary 'This talks about the stuff'" do
      before do
        @episode = Episode.new(:summary => 'This talks about the stuff')
      end

      it 'sets body accordingly' do
        @episode.body.should == @episode.summary
      end
    end

    describe "when a *saved* record is initialized with summary 'This talks about the stuff'" do
      before do
        @episode = Episode.create!(:title => 'Something')
        @episode.update_attributes!(:body => nil, :summary => 'Old summary')
        @episode = Episode.new(:summary => 'This talks about the stuff')
      end

      it 'sets body accordingly' do
        @episode.body.should == @episode.summary
      end
    end

    describe 'friendly_id' do
      [['my COOL tItLe!', 'my-cool-title'],
       ['你好',           'ni-hao'],
       ['Łódź, Poland',   'lodz-poland'],
      ].each do |title, slug|
        it "converts title '#{title}' to #{slug}" do
          @episode = Episode.create!(:title => title)
          @episode.friendly_id.should == slug
        end
      end

      it "when I create 2 episodes with default title 'New Post', the url for the 2nd episode gets a sequence ('new-episode--2')" do
        Episode.destroy_all
        @episode_1 = Episode.create!()
        @episode_1.cached_slug.should == 'new-episode'
        @episode_2 = Episode.create!()
        @episode_2.cached_slug.should == 'new-episode--2'
      end

      it "when I change the url/slug, it should still be accessable by the old as well as the new" do
        Episode.destroy_all
        @episode = Episode.create!()
        @episode.cached_slug.should == 'new-episode'

        @episode.update_attributes!(:url => 'a')
        @episode.cached_slug.should == 'a'

        @episode.should == Episode.find('new-episode')
        @episode.should == Episode.find('a')
      end

      # Updates slug automatically because custom url has not been set
      it "when I set title to 'A', then change title to 'B', url and cached_slug ends up being 'b'" do
        Episode.destroy_all
        @episode = Episode.create!(:title => 'A')
        @episode.url        .should == 'a'
        @episode.cached_slug.should == 'a'
        @episode.should_not be_custom_url

        @episode.update_attributes!(:title => 'B')
        @episode.url        .should == 'b'
        @episode.cached_slug.should == 'b'
        @episode.should_not be_custom_url
      end

      it "when I set title to 'A', causing the url to automatically be 'a', and then try to set manually url to 'a', the url attribute should not get updated because the new value is not different from the existing value" do
        Episode.destroy_all
        @episode = Episode.create!(:title => 'A')
        @episode.url        .should == 'a'
        @episode.cached_slug.should == 'a'
        @episode.should_not be_custom_url

        @episode.update_attributes!(:url => 'a')
        @episode.url        .should == 'a'
        @episode.cached_slug.should == 'a'
        @episode.should_not be_custom_url
      end

      # Setting custom url disables automatic slug generation
      it "when I set url to 'a', then change title to 'B', cached_slug remains at the custom url, 'a'" do
        Episode.destroy_all
        @episode = Episode.create!()
        @episode.url        .should == 'new-episode'
        @episode.cached_slug.should == 'new-episode'
        @episode.should_not be_custom_url

        @episode.update_attributes!(:url => 'a')
        @episode.url        .should == 'a'
        @episode.cached_slug.should == 'a'
        @episode.should be_custom_url

        @episode.update_attributes!(:title => 'B')
        @episode.url        .should == 'a'
        @episode.cached_slug.should == 'a'
      end

      1.times do
      it "when I set url to invalid url value '#{s='Invalid as URL'}', it converts it to something valid" do
        Episode.destroy_all
        @episode = Episode.create!()
        @episode.url        .should == 'new-episode'
        @episode.cached_slug.should == 'new-episode'
        @episode.should == Episode.find('new-episode')

        @episode.update_attributes!(:url => s)
        @episode.read_attribute(:url).should == 'invalid-as-url'
        @episode.url.                 should == 'invalid-as-url'
        @episode.cached_slug.         should == 'invalid-as-url'
        @episode.should == Episode.find('invalid-as-url')

        @episode.update_attributes!(:title => 'B')
        @episode.url        .should == 'invalid-as-url'
        @episode.cached_slug.should == 'invalid-as-url'
      end
      end

      1.times do
      it "when I set url to invalid url value '#{s='<blink>cool</blink>'}', it strips out the tags" do
        Episode.destroy_all
        @episode = Episode.create!()
        @episode.url        .should == 'new-episode'
        @episode.cached_slug.should == 'new-episode'
        @episode.should == Episode.find('new-episode')

        @episode.update_attributes!(:url => s)
        @episode.read_attribute(:url).should == 'cool'
        @episode.url.                 should == 'cool'
        @episode.cached_slug.         should == 'cool'
        @episode.should == Episode.find('cool')

        @episode.update_attributes!(:title => 'B')
        @episode.url        .should == 'cool'
        @episode.cached_slug.should == 'cool'
      end
      end

      [
        [nil]*2,
        ['']*2,
        ['<br>', '']
      ].each do |s, normalized_s|
        it "when I set url to #{s.inspect}, it goes back to creating the slug based on title" do
          Episode.destroy_all
          @episode = Episode.create!(:title => 'My title', :url => 'my-url')
          @episode.url        .should == 'my-url'
          @episode.cached_slug.should == 'my-url'
          @episode.should be_custom_url

          @episode.update_attributes!(:url => s)
          @episode.read_attribute(:url).should == normalized_s
          @episode.url        .should == 'my-title'
          @episode.cached_slug.should == 'my-title'
          @episode.should_not be_custom_url
        end
      end
    end

    describe "published?" do
      it 'when date is yesterday, it will report itself as being unpublished' do
        @episode = Episode.create!(:date => Date.new(2011,12,31))
        @episode.should_not be_published
      end

      it 'when date is today, it will report itself as being published' do
        @episode = Episode.create!(:date => Date.new(2011,1,1))
        @episode.should be_published
      end

    end

    describe "normalization" do
      [:title, :summary, :body].each do |attr_name|
        it { should normalize_attribute(attr_name).from('  Something  ').to('Something') }
        it { should normalize_attribute(attr_name).from('').to(nil) }
      end
    end

    describe "validation" do
     #describe "when it has the same url as another page" do
     #  it "should fail validation" do
     #    page1 = Episode.create(url: '/page1')
     #    page2 = Episode.create(url: '/page1')
     #    page2.should_not be_valid
     #    page2.errors[:url].should be_present
     #  end
     #end

      describe 'date' do
        it "accepts valid dates" do
          Episode.destroy_all
          page = Episode.new(url: '/page1', :date => '2011-02-10')
          page.should be_valid
        end

        it "doesn't accept valid date" do
          Episode.destroy_all
          page = Episode.new(url: '/page1')
          page.date = '2011-02-99'
          page.valid?
          page.should_not be_valid
          page.errors['date'].first.should match(/not a valid date/)
        end
      end

    end

    describe 'to_s' do
      it 'should return the title' do
        episode = Episode.new(:title => 'Home')
        episode.to_s.should match(/Home/)
      end
    end
  end
end
