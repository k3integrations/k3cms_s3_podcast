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

      describe 'image_url' do
        it "shouldn't allow invalid URLs" do
          podcast = Podcast.new(image_url: 'htt:/not.a.real.url/')
          podcast.valid?
          podcast.errors[:image_url].should be_present

          podcast = Podcast.new(image_url: 'http://a.real.url.com/')
          podcast.valid?
          podcast.errors[:image_url].should be_empty
        end
      end
    end

    describe 'to_s' do
      it 'should return the title' do
        podcast = Podcast.new(:title => 'My podcast')
        podcast.to_s.should match(/My podcast/)
      end
    end

    describe 'sources' do
      it 'should be initialized to an array' do
        podcast = Podcast.new
        podcast.sources.should be_instance_of(Array)
      end

      it 'should be required to have at least one source' do
        podcast = Podcast.new
        podcast.valid?
        podcast.errors[:sources].should be_present
      end

      it 'should ignore blank sources' do
        podcast = Podcast.new(:sources => ["http://example.com/{code}.m4a", nil, nil, ""])
        podcast.sources.should == ["http://example.com/{code}.m4a"]
      end

      it 'does not strip out blank sources when you modify the array directly, bypassing the sources= setter' do
        podcast = Podcast.make(:sources => ["http://example.com/{code}.m4a"])
        podcast.sources[4] = 'other'
        podcast.save
        podcast.reload.sources.should == ["http://example.com/{code}.m4a", nil, nil, nil, 'other']

        # but, source_1 works around this, triggering sources= setter 
        podcast.source_1 = '1'
        podcast.save
        podcast.reload.sources.should == ["http://example.com/{code}.m4a", '1', 'other']
  
      end
    end
  end
end
