require "csv"

class Account < ActiveRecord::Base
  default_scope -> { order("accounts.amount DESC") }

  scope :expenses, -> { where("accounts.amount > 0") } # Amount is flipped, positive numbers are expenses
  scope :income, -> { where("accounts.amount < 0") } # Amount is flipped, negative numbers are income

  # Returns all the top level accounts (ie 'Paragraffer')
  scope :top_level, -> { where({:parent_id => nil}) }

  belongs_to :parent, :class_name => name
  has_many :children, :class_name => name, :inverse_of => :parent, :foreign_key => "parent_id"

  before_save :remove_abbreviations_from_name

  class << self
    # Returns the total budget expenses for year in millions
    def total(year)
      @totals ||= {}
      @totals[year] ||= top_level.expenses.year(year).sum(:amount)
    end

    # Returns all accounts for the given year
    def year(year)
      where(:year => year)
    end
  end

  # Returns true if this is a child account
  def child?
    parent.present?
  end

  # Some top level accounts have income not coming from taxes. effective_amount
  # returns amount reduced by a percentage taking that other-taxly-income into
  # account
  def effective_amount
    return amount unless child?

    total_income_in_parent = parent.children.income.sum(:amount)
    total_expenses_in_parent = parent.children.expenses.sum(:amount)
    percentage_covered_by_income = (total_income_in_parent / total_expenses_in_parent).abs
    percentage_left_to_pay = 1 - percentage_covered_by_income

    amount * percentage_left_to_pay
  end

  # Returns the percentage (0..1) of the years total budget taken up by this account
  def percentage_of_total
    amount / Account.total(year)
  end

  # Returns the amount of DKK used in this account based on the given total tax payment
  def amount_of_tax_payment(tax_payment)
    tax_payment * effective_amount / Account.total(year)
  end

  private

  def remove_abbreviations_from_name
    self.name = (name || "").gsub("F & U", "Forskning og Udvikling")
    true # Don't break save chain
  end
end
