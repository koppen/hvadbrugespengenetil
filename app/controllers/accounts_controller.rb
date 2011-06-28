class AccountsController < ApplicationController

  def index
    @tax_amount = 300_000
    @year = 2011
    @accounts = Account.where({:year => @year})
    @total_amount = @accounts.sum(:amount)
  end

end
