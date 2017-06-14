require 'net/http'
require 'date'
require_relative 'database'

class FileFormatError < Exception; end

class ExchangeRateConverter

  RATES_HOST = 'sdw.ecb.europa.eu'
  RATES_RESOURCE = '/quickviewexport.do?SERIES_KEY=120.EXR.D.USD.EUR.SP00.A&type=csv'
  RATES_FILE = 'rates.csv'
  CSV_SEPARATOR = ','
  RATE_ZERO = 0.000001

  def self.download_rates
    Net::HTTP.start(RATES_HOST) { |http|
      resp = http.get(RATES_RESOURCE)
      open(RATES_FILE, 'w') { |file|
        file.write(resp.body)
      }
    }
  end

  def self.upload_rates_to_database
    data = File.open(RATES_FILE)
    header = data.readline

    unless header.start_with?('Data Source in SDW')
      raise FileFormatError.new
    end

    File.readlines(RATES_FILE).drop(5).each do |line|
      fields = line.split(CSV_SEPARATOR)
      if fields.size < 2
        next
      end

      date, rate = nil, nil
      begin
        date = Date.parse(fields[0])
        rate = fields[1].to_f
      rescue
        raise FileFormatError.new("Invalid field format: #{fields[0]} #{fields[0]}")
      end

      unless rate < RATE_ZERO
        store_rate_for_date(date, rate)
      end
    end
    true
  end

  def self.convert(amount, date)
    key = key_from_date(date)
    if key < MIN_DATE_KEY
      raise ArgumentError.new('Invalid date. Date must be from 2000 onwards')
    end

    date_key = key_from_date(date)

    begin
      rate = Database.read(date_key)
      if rate == nil
        date_key -= 1
      end
    end while rate == nil && date_key > MIN_DATE_KEY

    if rate
      (amount * rate.to_f).round(2)
    end
  end

  private

  def self.store_rate_for_date(date, rate)
    Database.store(key_from_date(date), rate)
  end

  def self.key_from_date(date)
    date_time = date
    unless date.respond_to?(:to_time)
      date_time = Date.parse(date)
    end
    date_time.to_time.to_i / (3600*24)
  end

  MIN_DATE_KEY = self.key_from_date('2001-01-01')

end