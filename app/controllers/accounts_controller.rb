class AccountsController < ApplicationController

  def index
    @year = (params[:year] || [Time.now.year - 1, 2010].max).to_i

    @tax_payment = params[:tax_payment]
    @tax_payment = (@tax_payment.to_i rescue nil)
    @tax_payment = nil if @tax_payment.zero?

    unless @tax_payment.blank?
      @state_tax = @tax_payment * (1 - CommunalAndChurchTax.average(@year))

      @accounts = Account.top_level.expenses.where({:year => @year}).includes(:children)
      @total_amount = Account.total(@year)
    end
  end

end
