module AccountsHelper

  def number_to_percentage(number)
    "#{(number * 100.0).round(1)}%"
  end

  def format_amount(amount)
    number_to_currency(amount.round, :unit => 'kr. ', :format => '%n %u', :delimiter => '.', :separator => ',', :precision => 0)
  end

  def amount_input_tag(name, value)
    options = {
      :autofocus => true,
      :min => 0,
      :placeholder => "en masse",
      :required => true,
        :type => :number
    }

    text_field_tag name, value, options
  end

end
