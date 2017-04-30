# frozen_string_literal: true

require_relative "../../spec_helper"

describe Source::Statbank do
  describe "importing from CSV" do
    before :each do
      # We don't want output in specs
      allow_any_instance_of(Source::Statbank).to receive(:output)
    end

    it "deletes existing accounts for the year" do
      existing_account = Account.create!(:year => 2012)

      Source::Statbank.new.import("spec/fixtures/statbank/2012.csv")

      expect(Account.find_by_id(existing_account.id)).to be_nil
    end

    it "preserves existing accounts for other years" do
      existing_account_from_another_year = Account.create!(:year => 2013)

      Source::Statbank.new.import("spec/fixtures/statbank/2012.csv")

      expect(
        Account.find_by_id(existing_account_from_another_year.id)
      ).to_not be_nil
    end

    it "imports top level accounts" do
      Source::Statbank.new.import("spec/fixtures/statbank/2012.csv")

      expect(Account.top_level.year(2012).count).to eq(2)
    end

    it "imports 2nd level accounts" do
      Source::Statbank.new.import("spec/fixtures/statbank/2012.csv")

      expect(Account.year(2012).where("parent_id IS NOT NULL").count).to eq(4)
    end
  end
end
