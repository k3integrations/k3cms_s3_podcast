# encoding: utf-8
require 'spec_helper'
require 'app/models/k3cms/s3_podcast/episode'

module K3cms::S3Podcast
  describe Episode do
    before do
      Time.stub!(:now).and_return(Time.mktime(2011,1,1, 12,0))
    end

    context 'publish_episodes_days_in_advance_of_date is 0 (default)' do
      before do
        @podcast = Podcast.make
        @episode_for_today       = @podcast.episodes.make(:date => Date.new(2011,1,1))
        @episode_1_day_in_future = @podcast.episodes.make(:date => Date.new(2011,1,2))
      end

      describe 'published scope' do
        subject { Rails.logger.debug "... Marker"; Episode.published }

        it { should == [@episode_for_today] }
      end

      describe "published?" do
        it 'when date of episode is today, it should consider itself published' do
          @episode_for_today.should be_published
        end

        it 'when date of episode is tomorrow, it should consider itself unpublished' do
          @episode_1_day_in_future.should be_unpublished
        end
      end
    end

    # When publish_episodes_days_in_advance_of_date is n, the published scope
    # should return episodes that have any date that is <= n days in the future.
    context 'publish_episodes_days_in_advance_of_date is 1' do
      before do
        @podcast = Podcast.make(:publish_episodes_days_in_advance_of_date => 1)
        @episode_for_today       = @podcast.episodes.make(:date => Date.new(2011,1,1))
        @episode_1_day_in_future = @podcast.episodes.make(:date => Date.new(2011,1,2))
        @episode_2_day_in_future = @podcast.episodes.make(:date => Date.new(2011,1,3))
      end

      describe 'published scope' do
        subject { Episode.published }

        it { should == [@episode_for_today, @episode_1_day_in_future] }

      end

      describe "published?" do
        it 'when date of episode is today, it should consider itself published' do
          @episode_for_today.should be_published
        end

        it 'when date of episode is 1 day in future, it should consider itself published' do
          @episode_1_day_in_future.should be_published
        end

        it 'when date of episode is 2 days in future, it should consider itself unpublished' do
          @episode_2_day_in_future.should be_unpublished
        end
      end
    end

    describe "normalization" do
      [:title, :description, :code].each do |attr_name|
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

      describe 'date' do
        it "accepts valid dates" do
          Episode.destroy_all
          episode = Episode.make_unsaved(:code => 'something', :date => '2011-02-10')
          episode.should be_valid
        end

        it "doesn't accept valid date" do
          Episode.destroy_all
          episode = Episode.new(code: 'code')
          episode.date = '2011-02-99'
          episode.valid?
          episode.should_not be_valid
          episode.errors['date'].first.should match(/not a valid date/)
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

      describe "when >=1 of the podcast's episode_source_urls contains {code}" do
        it 'should not allow code to be missing' do
          podcast = Podcast.make_unsaved(:episode_source_urls => ["http://example.com/{code}.m4a"])
          episode = podcast.episodes.make_unsaved(code: nil)
          episode.valid?
          episode.errors[:code].should include("can't be blank")
        end
      end
    end

    describe 'source_urls (with multiple sources)' do
      before do
        @podcast = Podcast.make(episode_source_urls: [
          "http://example.com/{code}.ogv",
          "http://example.com/{code}.m4v",
        ])
        @episode = Episode.new(code: 'my_code', podcast: @podcast)
      end

      it 'video_source_urls should return the video source_urls' do
        @episode.video_source_urls.should == ["http://example.com/my_code.ogv", "http://example.com/my_code.m4v"]
      end
    end

    describe 'source_urls' do
      let(:episode) { @episode = Episode.new(code: 'my_code', date: Date.new(2011, 5, 1), podcast: @podcast) }

      it 'should replace {code} with the actual code' do
        @podcast = Podcast.make(episode_source_urls: ["http://example.com/{code}.ogv"])
        episode.source_urls[0].should == "http://example.com/my_code.ogv"
      end

      it 'should replace {year} with the actual year' do
        @podcast = Podcast.make(episode_source_urls: ["http://example.com/{year}.ogv"])
        episode.source_urls[0].should == "http://example.com/2011.ogv"
      end

      it 'should replace {month} with the actual month, padded with 0s' do
        @podcast = Podcast.make(episode_source_urls: ["http://example.com/{month}.ogv"])
        episode.source_urls[0].should == "http://example.com/05.ogv"
      end

      it 'should replace {month} with the actual day, padded with 0s' do
        @podcast = Podcast.make(episode_source_urls: ["http://example.com/{day}.ogv"])
        episode.source_urls[0].should == "http://example.com/01.ogv"
      end
    end

    describe 'get_url' do
      it "given nil, should return nil" do
        episode = Episode.new
        episode.send(:get_url, nil).should be_nil
      end

      it "when code is nil and is referenced by the source_url, should return nil" do
        episode = Episode.new(code: nil)
        episode.send(:get_url, 'something_{code}').should be_nil
      end

      it "when code is nil but is NOT even referenced by the source_url, should not matter" do
        episode = Episode.new(code: nil, date: Date.new(2011,1,1))
        episode.send(:get_url, 'something_{year}').should == 'something_2011'
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
