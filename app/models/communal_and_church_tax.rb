# frozen_string_literal: true

class CommunalAndChurchTax
  # Numbers from
  # https://www.skm.dk/skattetal/satser/statistik-i-kommunerne/kommuneskatter-gennemsnitsprocenter-2007-2022/
  #
  # We're using the "Gennemsnitlige kommune- og kirkeskatteprocenter" > "I alt"
  # numbers here, as they include both communal and church taxes.
  AVERAGES = {
    2010 => 0.25641,
    2011 => 0.25656,
    2012 => 0.25654,
    2013 => 0.25630,
    2014 => 0.25617,
    2015 => 0.25613,
    2016 => 0.25612,
    2017 => 0.25606,
    2018 => 0.25597,
    2019 => 0.25604,
    2020 => 0.25629,
    2021 => 0.25641,
    2022 => 0.25647,
    2023 => 0.25679,
    2024 => 0.25715
  }.freeze

  # When we import data from OES CS the numbers only includes what the state
  # spends money on, not what regions and communes spend their money on.
  #
  # When we show results from years based on data from OES CS, we need to deduct
  # communal and regional taxes from the full tax payment.
  def self.deduct_communal_tax?(year)
    !Year.new(year).source.includes_communal_tax?
  end

  def self.average(year)
    AVERAGES.fetch(year)
  end

  def self.tax_payment_with_communal_tax_deducted(tax_payment, year)
    if deduct_communal_tax?(year)
      tax_payment * (1 - average(year))
    else
      tax_payment
    end
  end
end
