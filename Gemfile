# frozen_string_literal: true

source "http://rubygems.org"

ruby `cat .ruby-version`.strip

gem "pg", "< 1.0"
gem "rails", "~> 4.2.3"
gem "silent-postgres"

gem "compass-rails"
gem "fancy-buttons"
gem "haml"
gem "sass-rails"
gem "unicorn"

group :assets do
  gem "uglifier"
end

group :production do
  gem "rails_12factor"
end

group :development, :test do
  gem "rspec-rails"
end

group :development do
  gem "taps"
end
