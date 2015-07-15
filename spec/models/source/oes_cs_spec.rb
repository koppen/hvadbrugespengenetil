require_relative "../../spec_helper"

describe Source::OesCs do
  describe "importing from CSV" do
    before :each do
      # We don't want output in specs
      Source::OesCs.any_instance.stub(:output)
    end

    it "deletes existing accounts for the year" do
      existing_account = Account.create!(:year => 2012)

      Source::OesCs.new.import("spec/fixtures/oes_cs/2012.csv", 2012)

      Account.find_by_id(existing_account.id).should be_nil
    end

    it "preserves existing accounts for other years" do
      existing_account_from_another_year = Account.create!(:year => 2013)

      Source::OesCs.new.import("spec/fixtures/oes_cs/2012.csv", 2012)

      Account.find_by_id(existing_account_from_another_year.id).should_not be_nil
    end

    it "imports top level accounts" do
      Source::OesCs.new.import(Rails.root.join("spec/fixtures/oes_cs/2012.csv"), 2012)

      Account.top_level.year(2012).count.should == 2
    end

    it "imports 2nd level accounts" do
      Source::OesCs.new.import(Rails.root.join("spec/fixtures/oes_cs/2012.csv"), 2012)

      Account.year(2012).where("parent_id IS NOT NULL").count.should == 2
    end
  end
end
