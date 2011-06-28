class AccountsController < ApplicationController

  def index
    @year = 2010

    @tax_payment = params[:tax_payment]
    @tax_payment = (@tax_payment.to_i rescue nil)
    @tax_payment = nil if @tax_payment.zero?

    unless @tax_payment.blank?
      @accounts = Account.expense.where({:year => @year})
      @total_amount = Account.total(@year)
    end
  end

end
