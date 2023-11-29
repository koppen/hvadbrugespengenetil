# frozen_string_literal: true

# Contain information about how data for each year was imported
class Year
  attr_reader :year

  SOURCES = {
    2010 => Source::Statbank,
    2011 => Source::Statbank,
    2012 => Source::Statbank,
    2013 => Source::OesCs,
    2014 => Source::OesCs,
    2015 => Source::OesCs,
    2016 => Source::OesCs,
    2020 => Source::OesCs,
    2021 => Source::Statbank,
    2022 => Source::OesCs,
    2023 => Source::OesCs,
  }.freeze

  # Returns the most recent year with data
  def self.most_recent
    new(Account.maximum(:year))
  end

  def initialize(year)
    @year = year
  end

  def source
    SOURCES[year]
  end
end
