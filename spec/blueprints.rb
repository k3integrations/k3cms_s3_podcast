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
    media_type 'Audio'
    url nil
    description 'Description'
    summary 'Summary'
    author { User.first || User.make }
  end

  Sham.code  {|i| "#{i}" }

  Episode.blueprint do
    code         { Sham.code }
    title        { Sham.title }
    display_date { Date.tomorrow }
  end
end
