# Contain information about how data for each year was imported
class Year
  SOURCES = {
    2010 => Source::Statbank,
    2011 => Source::Statbank,
    2012 => Source::Statbank,
    2013 => Source::OesCs
  }

  def initialize(year)
    @year = year
  end

  def source
    SOURCES[year]
  end

  private

  attr_reader :year
end
