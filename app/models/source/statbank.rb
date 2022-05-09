# frozen_string_literal: true

module Source
  # Danmarks Statistik publishes "OFF29:  OFF29: General government, COFOG"
  # http://www.statbank.dk/OFF29
  #
  class Statbank
    # Returns true if the numbers imported from this source includes income from
    # communal taxes
    def self.includes_communal_tax?
      true
    end

    # Imports data exported from http://www.statbank.dk/OFF29
    #
    # Expects the export to be in CSV format, contain a single year, include all
    # functions, and have function codes in separate columns.
    def import(path)
      year = nil # We'll grab the year from the CSV

      Account.transaction do
        row_index = 0
        CSV.foreach(path, :encoding => "iso8859-1") do |row|
          row_index += 1

          # Row 4 contains the year
          if row_index == 4
            year = row.last
            remove_existing_accounts(year)
          end

          # The first 6 rows are headers with info
          import_row(row, year) unless row_index < 6
        end
      end
    end

    private

    def create_account(title, amount, year)
      key_parts, name = parse_title_into_key_parts_and_name(title)
      parent = parent_account(key_parts, year)

      Account.create(
        :key => key_parts.join("."),
        :name => name,
        :amount => amount,
        :year => year,
        :parent => parent
      )
    end

    def import_row(row, year)
      title = row[0].to_s
      amount = row[1]
      create_account(title, amount, year) unless title.blank?
    end

    def parent_account(key_parts, year)
      if top_level?(key_parts)
        nil
      else
        # Sub account, find the parent
        Account.where(:year => year, :key => key_parts.first).first
      end
    end

    def parse_title_into_key_parts_and_name(title)
      key, name = title.split(" ", 2).collect(&:strip)
      key_parts = key.to_s.split(".")
      [key_parts, name]
    end

    def remove_existing_accounts(year)
      Account.where(:year => year).destroy_all
    end

    # Top level or sub-account?
    def top_level?(key_parts)
      key_parts.size == 1
    end
  end
end
