require 'machinist/active_record'
require 'sham'

module K3cms::S3Podcast
  User.blueprint do
    email 'user@example.com'
    password 'password'
  end

  Sham.title {|i| "Title #{i}" }

  Podcast.blueprint do
    title        { Sham.title }
    description 'Description'
    summary 'Summary'
    author { User.first || User.make }
    image_url "http://example.com/{code}.png"
    sources  ["http://example.com/{code}.m4a", "http://example.com/{code}.ogg"]
  end

  Sham.code  {|i| "#{i}" }

  Episode.blueprint do
    podcast      { Podcast.first || Podcast.make }
    code         { Sham.code }
    title        { Sham.title }
    display_date { Date.tomorrow }
  end
end
