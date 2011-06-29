module AccountsHelper

  def number_to_percentage(number)
    "#{(number * 100.0).round(1)}%"
  end

end
