class AccountsController < ApplicationController

  # From http://www.skm.dk/tal_statistik/kommuneskatter/7910.html
  AVERAGE_COMMUNAL_AND_CHURCH_TAX = {
    2010 => 0.25641,
    2011 => 0.25656,
    2012 => 0.25654
  }

  def index
    @year = (params[:year] || [Time.now.year - 1, 2010].max).to_i

    @tax_payment = params[:tax_payment]
    @tax_payment = (@tax_payment.to_i rescue nil)
    @tax_payment = nil if @tax_payment.zero?

    unless @tax_payment.blank?
      @state_tax = @tax_payment * (1 - (AVERAGE_COMMUNAL_AND_CHURCH_TAX[@year] || 0))

      @accounts = Account.top_level.expenses.where({:year => @year}).includes(:children)
      @total_amount = Account.total(@year)
    end
  end

end
