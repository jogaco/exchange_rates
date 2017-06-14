require_relative 'exchange_rate_converter'

task default: %w[load_rates]

task :load_rates do
  ExchangeRateConverter.load_rates_into_database
end