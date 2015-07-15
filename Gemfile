source "http://rubygems.org"
ruby "1.9.3"

gem "rails", "~> 3.2.0"
gem "pg"
gem "silent-postgres"

gem "haml"
gem "unicorn"

group :assets do
  gem "compass-rails"
  gem "fancy-buttons"
  gem "sass-rails"
  gem "uglifier"
end

group :production do
  gem "rails_12factor"
end

group :development, :test do
  gem "rspec-rails"
end

group :development do
  gem "heroku"
  gem "taps"
end
