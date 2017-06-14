require 'net/http'

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
        Database.store(key_from_date(date), rate)
      end
    end
  end

  private

  def self.key_from_date(date)
    date.to_time.to_i / (3600*24)
  end


end