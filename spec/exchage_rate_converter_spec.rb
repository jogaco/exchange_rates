require 'spec_helper'
require_relative '../exchange_rate_converter'

describe ExchangeRateConverter do
  describe '#download_rates' do
    it 'should connect to url and download file' do
      url = "#{ExchangeRateConverter::RATES_HOST}#{ExchangeRateConverter::RATES_RESOURCE}"
      headers = {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}

      stub_request(:get, url).with(:headers => headers).to_return(:status => 200, :body => '{}', :headers => {})

      ExchangeRateConverter.download_rates

      expect(WebMock).to have_requested(:get, url).with(:headers => headers)
    end
  end
end