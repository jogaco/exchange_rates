require 'net/http'

class ExchangeRateConverter

  RATES_HOST = 'sdw.ecb.europa.eu'
  RATES_RESOURCE = '/quickviewexport.do?SERIES_KEY=120.EXR.D.USD.EUR.SP00.A&type=csv'

  def self.download_rates
    Net::HTTP.start(RATES_HOST) { |http|
      resp = http.get(RATES_RESOURCE)
      open('rates.csv', 'w') { |file|
        file.write(resp.body)
      }
    }
  end

end