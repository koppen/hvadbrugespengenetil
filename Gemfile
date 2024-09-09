# frozen_string_literal: true

source "http://rubygems.org"

ruby `cat .ruby-version`.strip

gem "sqlite3", "~> 1.3.6"
gem "rails", "~> 4.2.3"

gem "compass-rails", "4.0.0"
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
  gem "rubocop", :require => false
  gem "rubocop-rails", :require => false
  gem "rubocop-rspec", :require => false
  gem "taps"
end
