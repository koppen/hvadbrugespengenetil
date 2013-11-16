class CommunalAndChurchTax

  # When we import data from OES CS the numbers only includes what the state
  # spends money on, not what regions and communes spend their money on.
  #
  # When we show results from years based on data from OES CS, we need to deduct
  # communal and regional taxes from the full tax payment.
  def self.deduct_communal_tax?(year)
    oes_cs_years = [2011, 2013]
    oes_cs_years.include?(year)
  end

  def self.average(year)
    {
      2010 => 0.25641,
      2011 => 0.25656,
      2012 => 0.25654
    }[year]
  end

  def self.tax_payment_with_communal_tax_deducted(tax_payment, year)
    if deduct_communal_tax?(year)
      tax_payment * (1 - average(year))
    else
      tax_payment
    end
  end

end
