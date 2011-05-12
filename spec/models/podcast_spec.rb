require 'spec_helper'

module K3cms::S3Podcast
  describe Podcast do
    describe 'blueprint' do
      it 'should be valid' do
        podcast = Podcast.make
        podcast.should be_valid
      end
    end

    describe "normalization" do
      [:title, :summary, :description].each do |attr_name|
        it { should normalize_attribute(attr_name).from('  Something  ').to('Something') }
        it { should normalize_attribute(attr_name).from('').to(nil) }
      end
    end

    describe "validation" do
      describe "blank podcast" do
        it "shouldn't be valid" do
          podcast = Podcast.new
          podcast.should_not be_valid
          podcast.errors[:title].should be_present
        end
      end

      ['publish_episodes_days_in_advance_of_date'].each do |attr_name|
        describe attr_name do
          it "shouldn't allow blank values" do
            podcast = Podcast.new
            podcast[attr_name] = nil 
            podcast.valid?
            podcast.errors[attr_name].should include("can't be blank")

            podcast[attr_name] = 'not blank'
            podcast.valid?
            podcast.errors[attr_name].should_not include("can't be blank")
          end
        end
      end

      ['episode_image_url', 'icon_url', 'logo_url', 'episode_source_urls'].each do |attr_name|
        describe attr_name do
          it "shouldn't allow invalid URLs" do
            podcast = Podcast.new(attr_name => 'htt:/not.a.real.url/')
            podcast.valid?
            podcast.errors[attr_name].should be_present

            podcast = Podcast.new(attr_name => 'http://a.real.url.com/')
            podcast.valid?
            podcast.errors[attr_name].should be_empty
          end
        end
      end
    end

    describe 'to_s' do
      it 'should return the title' do
        podcast = Podcast.new(:title => 'My podcast')
        podcast.to_s.should match(/My podcast/)
      end
    end

    describe 'episode_source_urls' do
      it 'should be initialized to an array' do
        podcast = Podcast.new
        podcast.episode_source_urls.should be_instance_of(Array)
      end

      it 'should coerce it to an array if you set it to a non-array' do
        podcast = Podcast.new(:episode_source_urls => 'not_an_array')
        podcast.episode_source_urls.should be_instance_of(Array)
      end

      it 'should still be an array when you reload the record' do
        podcast = Podcast.make(:episode_source_urls => ["http://example.com/"])
        podcast.reload.episode_source_urls.should == ["http://example.com/"]
      end

      it 'should be required to have at least one source' do
        podcast = Podcast.new
        podcast.valid?
        podcast.errors[:episode_source_urls].should be_present
      end

      it 'should ignore blank episode_source_urls' do
        podcast = Podcast.new(:episode_source_urls => ["http://example.com/{code}.m4a", nil, nil, ""])
        podcast.episode_source_urls.should == ["http://example.com/{code}.m4a"]
      end

      it 'does not strip out blank episode_source_urls when you modify the array directly, bypassing the episode_source_urls= setter' do
        podcast = Podcast.make(:episode_source_urls => ["http://example.com/{code}.m4a"])
        podcast.episode_source_urls[4] = 'other'
        podcast.should_not be_valid
        podcast.errors[:episode_source_urls].should be_present
        podcast.episode_source_urls.should == ["http://example.com/{code}.m4a", nil, nil, nil, 'other']

        # but, source_1 works around this, triggering episode_source_urls= setter 
        podcast.source_1 = '1'
        podcast.episode_source_urls.should == ["http://example.com/{code}.m4a", '1', 'other']
  
      end
    end
  end
end
