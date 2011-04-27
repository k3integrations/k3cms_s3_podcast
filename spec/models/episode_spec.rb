# encoding: utf-8
require 'spec_helper'
require 'app/models/k3cms/s3_podcast/episode'

module K3cms::S3Podcast
  describe Episode do
    before do
      Time.stub!(:now).and_return(Time.mktime(2011,1,1, 12,0))
    end


    describe "published?" do
      it 'when published_at is yesterday, it will report itself as being unpublished' do
        @episode = Episode.make(:published_at => Date.new(2011,12,31))
        @episode.should_not be_published
      end

      it 'when published_at is today, it will report itself as being published' do
        @episode = Episode.make(:code => 'something', :published_at => Date.new(2011,1,1))
        @episode.should be_published
      end

    end

    describe "normalization" do
      [:title, :description].each do |attr_name|
        it { should normalize_attribute(attr_name).from('  Something  ').to('Something') }
        it { should normalize_attribute(attr_name).from('').to(nil) }
      end
    end

    describe "validation" do
      describe "blank episode" do
        it "shouldn't be valid" do
          episode = Episode.new
          episode.should_not be_valid
        end
      end

      describe 'published_at' do
        it "accepts valid dates" do
          Episode.destroy_all
          episode = Episode.make_unsaved(:code => 'something', :published_at => '2011-02-10')
          episode.should be_valid
        end

        it "doesn't accept valid date" do
          Episode.destroy_all
          episode = Episode.new(code: 'code')
          episode.published_at = '2011-02-99'
          episode.valid?
          episode.should_not be_valid
          episode.errors['published_at'].first.should match(/not a valid date/)
        end
      end

      describe 'uniqueness of code' do
        it "doesn't allow two records to have same code" do
          e1 = Episode.        make(code: 'A')
          e2 = Episode.make_unsaved(code: 'A')
          e2.valid?
          e2.errors[:code].should be_present
        end

        it "does allow two records to have same code if they are for different podcasts" do
          podcast_1 = Podcast.make; e1 = podcast_1.episodes.        make(code: 'A')
          podcast_2 = Podcast.make; e2 = podcast_2.episodes.make_unsaved(code: 'A')
          e2.should be_valid
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
