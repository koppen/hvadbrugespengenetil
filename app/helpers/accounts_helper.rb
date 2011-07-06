module AccountsHelper

  def number_to_percentage(number)
    "#{(number * 100.0).round(1)}%"
  end

  def format_amount(amount)
    number_to_currency(amount.round, :unit => 'kr. ', :format => '%n %u', :delimiter => '.', :separator => ',', :precision => 0)
  end

end
