class AccountsController < ApplicationController

  def index
    @tax_payment = params[:tax_payment]
    @tax_payment = (@tax_payment.to_i rescue nil)
    unless @tax_payment.blank?
      @year = 2011
      @accounts = Account.expense.where({:year => @year})
      @total_amount = Account.total(@year)
    end
  end

end
