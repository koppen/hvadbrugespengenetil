require_relative '../spec_helper'

describe "Account" do
  describe ".year" do
    it "returns only accounts for that year" do
      [2011, 2012, 2013, 2012].each do |year|
        Account.create!(:year => year)
      end
      Account.year(2012).collect(&:year).uniq.should == [2012]
    end
  end
end
