module Source
  # Finansministeriet/Moderniseringsstyrelsen publishes numbers from the
  # governmental budget and it's predictions for the next 3 years at
  # http://www.oes-cs.dk/olapdatabase/finanslov/index.cgi
  #
  # The numbers under income doesn't include communal and regional taxes.
  class OesCs
    # Returns true if the numbers imported from this source includes income from
    # communal taxes
    def self.includes_communal_tax?
      false
    end

    # Imports data exported from http://www.oes-cs.dk/olapdatabase/finanslov/index.cgi
    #
    # The CSV should contain "Paragraf, Hovedområde" and show all account levels
    def import(path, year = nil)
      year = (year || Date.today.year).to_s

      lines = clean_up_csv(path)

      Account.transaction do
        # Remove the existing accounts for the year
        Account.where(:year => year).destroy_all

        CSV.parse(lines, :encoding => "iso8859-1", :col_sep => ';', :headers => :first_row) do |row|
          import_row(row, year)
        end
      end
    end

    private

    # Picks the CSV apart, removes trailing spaces (that are invalid), and
    # reassemble for the CSV parser.
    def clean_up_csv(path)
      File.readlines(path, "\r\n", encoding: "iso8859-1").collect(&:strip).join("\n")
    end

    def import_row(row, year)
      output "row: #{row.inspect}"
      title = row[0].strip
      key, name = title.split(' ', 2).collect(&:strip)

      amount = parse_amount(row[year.to_s])
      parent = parent_account(key, year)

      Account.create(
        :key => key,
        :name => name,
        :amount => amount,
        :year => year,
        :parent => parent
      )
    end

    def output(message)
      puts message
    end

    def parent_account(key, year)
      if top_level_account?(key)
        nil
      else
        # Sub account, find the parent
        parent_key = key.first(2)
        Account.find_by_year_and_key(year, parent_key)
      end
    end

    # We get amounts formatted like "4.234,1" when we want "4234.1" (or "4_234.1")
    def parse_amount(amount)
      amount.strip.tr('.,', '_.')
    end

    # Top level or sub-account ('Paragraf' or 'Hovedområde')?
    def top_level_account?(account_key)
      account_key.length == 2
    end
  end
end
