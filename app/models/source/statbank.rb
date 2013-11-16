module Source
  # Danmarks Statistik publishes "OFF23: Classifications of functions of
  # government expenditures by function (Yearly)" at
  # http://www.statbank.dk/OFF23
  #
  class Statbank
    # Imports data exported from http://www.statbank.dk/OFF23
    #
    # Expects the export to be in CSV format, contain a single year, include all
    # functions, and have function codes in separate columns.
    def import(path)
      year = nil # We'll grab the year from the CSV

      Account.transaction do
        row_index = 0
        CSV.foreach(path, :encoding => "iso8859-1") do |row|
          row_index += 1
          if row_index == 4 # Row 4 contains the year
            year = row.last
            # Remove the existing accounts for the year
            Account.where(:year => year).destroy_all
          end
          next if row_index < 6 # The first 6 rows are headers with info

          title = row[0].to_s
          next if title.blank?

          key, name = title.split(' ', 2).collect(&:strip)
          key_parts = key.to_s.split('.')
          amount = row[1]

          # Top level or sub-account
          parent = if key_parts.size == 1
            # Top level
            nil
          else
            # Sub account, find the parent
            Account.where(:year => year, :key => key_parts.first).first
          end

          Account.create(
            :key => key_parts.join('.'),
            :name => name,
            :amount => amount,
            :year => year,
            :parent => parent
          )
        end
      end
    end
  end
end
