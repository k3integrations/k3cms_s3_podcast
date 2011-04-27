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
          podcast.errors['title'].should be_present
        end
      end
    end

    describe 'to_s' do
      it 'should return the title' do
        podcast = Podcast.new(:title => 'My podcast')
        podcast.to_s.should match(/My podcast/)
      end
    end
  end
end
