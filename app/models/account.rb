class Account < ActiveRecord::Base
  default_scope order('amount DESC')

  scope :expenses, where('amount > 0') # Amount is flipped, positive numbers are expenses
  scope :income, where('amount < 0') # Amount is flipped, negative numbers are income

  # Returns all the top level accounts (ie 'Paragraffer')
  scope :top_level, where({:parent_id => nil})

  belongs_to :parent, :class_name => name
  has_many :children, :class_name => name, :inverse_of => :parent, :foreign_key => 'parent_id'

  class << self

    # Returns the total budget expenses for year in millions
    def total(year)
      top_level.expenses.sum(:amount, :conditions => {:year => year})
    end

    def import_from_csv(file, year = nil)
      year = (year || Date.today.year).to_s

      Account.transaction do
        # Remove the existing accounts for the year
        Account.where(:year => year).destroy_all

        FasterCSV.foreach(file, :col_sep => ';', :headers => :first_row) do |row|
          puts "row: #{row.inspect}"
          title = row[0]
          key, name = title.split(' ', 2).collect(&:strip)

          # We get amounts formatted like "4.234,1" when we want "4234.1" (or "4_234.1")
          amount = row[year.to_s]
          amount = amount.tr('.,', '_.')

          # Top level or sub-account ('Paragraf' or 'Hovedområde')?
          parent = if key.length == 2
            # Top level
            nil
          else
            # Sub account, find the parent
            parent_key = key.first(2)
            Account.find_by_key(parent_key)
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

    # Imports OFF23 exported as CSV from http://www.statbank.dk/OFF23
    def import_from_statbank(file)
      year = nil # We'll grab the year from the CSV

      Account.transaction do
        row_index = 0
        FasterCSV.foreach(file) do |row|
          row_index += 1
          if row_index == 4 # Row 4 contains the year
            year = row.last
            # Remove the existing accounts for the year
            Account.where(:year => year).destroy_all
          end
          next if row_index < 6 # The first 6 rows are headers with info

          title = row[0]
          key, name = title.split(' ', 2).collect(&:strip)
          key_parts = key.split('.')
          amount = row[1]

          # Top level or sub-account
          parent = if key_parts.size == 1
            # Top level
            nil
          else
            # Sub account, find the parent
            Account.find_by_key(key_parts.first)
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

  # Returns the percentage (0..1) of the years total budget taken up by this account
  def percentage_of_total
    self.amount / Account.total(self.year)
  end

  # Returns the amount of DKK used in this account based on the given total tax payment
  def amount_of_tax_payment(total_tax_payment)
    total_tax_payment * self.amount / Account.total(self.year)
  end

end
