require_relative "../spec_helper"

describe "Year" do
  describe ".source" do
    it "returns nil for unknown years" do
      year = Year.new(2000)
      expect(year.source).to be_nil
    end

    it "returns source for year" do
      year = Year.new(2012)
      expect(year.source).to eq(Source::Statbank)

      year = Year.new(2013)
      expect(year.source).to eq(Source::OesCs)
    end
  end
end
