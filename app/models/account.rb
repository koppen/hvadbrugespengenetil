class Account < ActiveRecord::Base
  default_scope order('accounts.amount DESC')

  scope :expenses, where('accounts.amount > 0') # Amount is flipped, positive numbers are expenses
  scope :income, where('accounts.amount < 0') # Amount is flipped, negative numbers are income

  # Returns all the top level accounts (ie 'Paragraffer')
  scope :top_level, where({:parent_id => nil})

  belongs_to :parent, :class_name => name
  has_many :children, :class_name => name, :inverse_of => :parent, :foreign_key => 'parent_id'

  before_save :remove_abbreviations_from_name

  class << self
    extend ActiveSupport::Memoizable

    # Returns the total budget expenses for year in millions
    def total(year)
      top_level.expenses.where(:year => year).sum(:amount)
    end
    memoize :total

    # Imports data exported from http://www.oes-cs.dk/olapdatabase/finanslov/index.cgi
    def import_from_finanslov(file, year = nil)
      year = (year || Date.today.year).to_s

      # Fix CSV. OES-CS returns the CSV in ISO8859-1, with "\r\n" as newlines.
      lines = File.readlines(file).map(&:strip).join("\n")
      lines = Iconv.conv('utf-8', 'iso-8859-1', lines)

      Account.transaction do
        # Remove the existing accounts for the year
        Account.where(:year => year).destroy_all

        FasterCSV.parse(lines, :col_sep => ';', :headers => :first_row) do |row|
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

  # Returns true if this is a child account
  def child?
    self.parent.present?
  end

  # Some top level accounts have income not coming from taxes. effective_amount
  # returns amount reduced by a percentage taking that other-taxly-income into
  # account
  def effective_amount
    return amount unless child?

    total_income_in_parent = parent.children.income.sum(:amount)
    total_expenses_in_parent = parent.children.expenses.sum(:amount)
    percentage_covered_by_income = (total_income_in_parent/total_expenses_in_parent).abs
    percentage_left_to_pay = 1 - percentage_covered_by_income

    self.amount * percentage_left_to_pay
  end

  # Returns the percentage (0..1) of the years total budget taken up by this account
  def percentage_of_total
    self.amount / Account.total(self.year)
  end

  # Returns the amount of DKK used in this account based on the given total tax payment
  def amount_of_tax_payment(tax_payment)
    tax_payment * self.effective_amount / Account.total(self.year)
  end

private

  def remove_abbreviations_from_name
    self.name = (self.name || '').gsub('F & U', 'Forskning og Udvikling')
    true # Don't break save chain
  end

end
