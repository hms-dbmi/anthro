# Anthro

A Ruby gem for calculating anthropometric z-scores and percentiles based on the [WHO Growth Charts](https://www.cdc.gov/growthcharts/who-data-files.htm) and [CDC Growth Charts](https://www.cdc.gov/growthcharts/cdc-data-files.htm).

## Installation

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add anthro
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install anthro
```

## Usage

### Convenience Methods (Recommended)

```ruby
require 'anthro'

# Weight (month-based)
calc = Anthro.weight_for_age(sex: "male", age_months: 24.5, value: 13.0)
puts "Z-Score: #{calc.z_score.round(2)}"
puts "Percentile: #{calc.percentile.round(2)}%"

# Weight (days-based): days devided by 30.4375
calc = Anthro.weight_for_age(sex: "male", age_days: 3653, value: 33.0) # ~120 months
puts "Z-Score: #{calc.z_score.round(2)}"
puts "Percentile: #{calc.percentile.round(2)}%"

# Height
calc = Anthro.height_for_age(sex: "female", age_days: 1461, value: 100.0) # ~48 months
puts "Z-Score: #{calc.z_score.round(2)}"
puts "Percentile: #{calc.percentile.round(2)}%"

# BMI
calc = Anthro.bmi_for_age(sex: "male", age_months: 36, value: 16.0)
puts "Z-Score: #{calc.z_score.round(2)}"
puts "Percentile: #{calc.percentile.round(2)}%"

# Head Circumference
calc = Anthro.head_circumference_for_age(sex: "female", age_months: 12, value: 46.0)
puts "Z-Score: #{calc.z_score.round(2)}"
puts "Percentile: #{calc.percentile.round(2)}%"
```

### Supported Measurements

- `Anthro.weight_for_age(sex:, age_months: or age_days:, value:)` (0–20 years)
- `Anthro.height_for_age(sex:, age_months: or age_days:, value:)` (0–20 years)
- `Anthro.bmi_for_age(sex:, age_months: or age_days:, value:)` (2–20 years)
- `Anthro.head_circumference_for_age(sex:, age_months: or age_days:, value:)` (0–2 years)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Data

This gem includes WHO and CDC 2000 growth chart data from [WHO Growth Charts Data files](https://www.cdc.gov/growthcharts/who-data-files.htm) and [CDC Growth Charts Data Files](https://www.cdc.gov/growthcharts/cdc-data-files.htm).

- Birth to 2 years (WHO)
  - [Weight-for-age charts: Boys](https://ftp.cdc.gov/pub/Health_Statistics/NCHS/growthcharts/WHO-Boys-Weight-for-age-Percentiles.csv)
  - [Weight-for-age charts: Girls](https://ftp.cdc.gov/pub/Health_Statistics/NCHS/growthcharts/WHO-Girls-Weight-for-age%20Percentiles.csv)
  - [Length-for-age charts: Boys](https://ftp.cdc.gov/pub/Health_Statistics/NCHS/growthcharts/WHO-Boys-Length-for-age-Percentiles.csv)
  - [Length-for-age charts: Girls](https://ftp.cdc.gov/pub/Health_Statistics/NCHS/growthcharts/WHO-Girls-Length-for-age-Percentiles.csv)
  - [Head circumference-for-age charts: Boys](https://ftp.cdc.gov/pub/Health_Statistics/NCHS/growthcharts/WHO-Boys-Head-Circumference-for-age-Percentiles.csv)
  - [Head circumference-for-age charts: Girls](https://ftp.cdc.gov/pub/Health_Statistics/NCHS/growthcharts/WHO-Girls-Head-Circumference-for-age-Percentiles.csv)

- 2 to 20 years (CDC)

  - [Weight-for-age charts](https://www.cdc.gov/growthcharts/data/zscore/wtage.csv)
  - [Stature-for-age charts](https://www.cdc.gov/growthcharts/data/zscore/statage.csv)
  - [BMI-for-age charts](https://www.cdc.gov/growthcharts/data/zscore/bmiagerev.csv)

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/hms-dbmi/anthro.

## License

See the [LICENSE](LICENSE.md) file for license rights and limitations (MIT).
