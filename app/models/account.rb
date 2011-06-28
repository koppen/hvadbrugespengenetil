class Account < ActiveRecord::Base
  default_scope order(:key)

  class << self

    # Returns the total budget amount for year in millions
    def total(year)
      sum(:amount, :conditions => {:year => year})
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
