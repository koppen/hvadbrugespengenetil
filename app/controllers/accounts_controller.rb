# frozen_string_literal: true

class AccountsController < ApplicationController
  def index
    @year = (params[:year] || Account.pluck(:year).max).to_i

    @tax_payment = params[:tax_payment]
    @tax_payment = (begin
      @tax_payment.to_i
    rescue StandardError
      nil
    end)
    @tax_payment = nil if @tax_payment.zero?

    unless @tax_payment.blank?
      @state_tax = CommunalAndChurchTax.tax_payment_with_communal_tax_deducted(@tax_payment, @year)
      @communal_tax_deducted = CommunalAndChurchTax.deduct_communal_tax?(@year)

      @accounts = Account.top_level.expenses.where(:year => @year).includes(:children)
      @total_amount = Account.total(@year)
    end
  end
end
