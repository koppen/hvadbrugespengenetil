require_relative "../spec_helper"

describe "Year" do
  describe ".source" do
    it "returns nil for unknown years" do
      year = Year.new(2000)
      year.source.should be_nil
    end

    it "returns source for year" do
      year = Year.new(2012)
      year.source.should == Source::Statbank

      year = Year.new(2013)
      year.source.should == Source::OesCs
    end
  end
end
