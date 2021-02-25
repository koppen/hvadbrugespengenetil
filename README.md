# Hvad Bruges Pengene Til?

## Configure communal and church tax

At https://www.skm.dk/skattetal/satser/statistik-i-kommunerne/kommuneskatter-gennemsnitsprocenter-2007-2021/ you'll find a table of average communal and church tax rates across Denmark for a given year.

`CommunalAndChurchTax::AVERAGES` in `app/models/communal_and_church_tax.rb` should be kept up to date with those numbers, using the "I alt gennemsnitlig kommunal skat" row.

## Import data

### From OES CS

1. Go to https://www.oes-cs.dk/olapdatabase/finanslov/index.cgi
2. Under "Struktur", choose only "Paragraf", "Hovedområde", and make sure "Alle niveauer på én gang" is enabled.
3. Choose the year under "Filter"
4. Click "Download" and save the file locally.
5. Run `rails runner 'Source::OesCs.new.import("<path to file>", <year>)'`
6. Add the year to `Year::SOURCES` in `app/models/year.rb`, ie like `2020 => Source::OesCs`.
