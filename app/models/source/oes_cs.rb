module Source
  # Finansministeriet/Moderniseringsstyrelsen published numbers from the
  # governmental budget and it's predictions for the next 3 years at
  # http://www.oes-cs.dk/olapdatabase/finanslov/index.cgi
  #
  # The numbers under income doesn't include communal and regional taxes.
  class OesCs
    # Imports data exported from http://www.oes-cs.dk/olapdatabase/finanslov/index.cgi
    def import(path, year = nil)
      year = (year || Date.today.year).to_s

      lines = clean_up_csv(path)

      Account.transaction do
        # Remove the existing accounts for the year
        Account.where(:year => year).destroy_all

        CSV.parse(lines, :encoding => "iso8859-1", :col_sep => ';', :headers => :first_row) do |row|
          output "row: #{row.inspect}"
          title = row[0].strip
          key, name = title.split(' ', 2).collect(&:strip)

          # We get amounts formatted like "4.234,1" when we want "4234.1" (or "4_234.1")
          amount = row[year.to_s].strip
          amount = amount.tr('.,', '_.')

          # Top level or sub-account ('Paragraf' or 'Hovedområde')?
          parent = if key.length == 2
            # Top level
            nil
          else
            # Sub account, find the parent
            parent_key = key.first(2)
            Account.find_by_year_and_key(year, parent_key)
          end

          Account.create(
            :key => key,
            :name => name,
            :amount => amount,
            :year => year,
            :parent => parent
          )
        end
      end
    end

    private

    # Picks the CSV apart, removes trailing spaces (that are invalid), and
    # reassemble for the CSV parser.
    def clean_up_csv(path)
      File.readlines(path, "\r\n", encoding: "iso8859-1").collect(&:strip).join("\n")
    end

    def output(message)
      puts message
    end
  end
end
