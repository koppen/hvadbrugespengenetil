class Account < ActiveRecord::Base
  default_scope order('amount DESC')

  scope :expense, where('amount > 0') # Amount is flipped, positive numbers are expenses
  scope :income, where('amount < 0') # Amount is flipped, negative numbers are income

  class << self

    # Returns the total budget expenses for year in millions
    def total(year)
      expense.sum(:amount, :conditions => {:year => year})
    end

    def import_from_csv(file, year = nil)
      year = (year || Date.today.year).to_s

      Account.transaction do
        # Remove the existing accounts for the year
        Account.where(:year => year).destroy_all

        FasterCSV.foreach(file, :col_sep => ';', :headers => :first_row) do |row|
          title = row[0]
          key, name = title.split(' ', 2)

          # We get amounts formatted like "4.234,1" when we want "4234.1" (or "4_234.1")
          amount = row[year.to_s]
          amount = amount.tr('.,', '_.')

          Account.create(
            :key => key,
            :name => name,
            :amount => amount,
            :year => year
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
