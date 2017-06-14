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

  describe '#upload_rates_to_database' do
    it 'should upload each exchange rate to the database' do
      allow(Database).to receive(:store)

      expect(Database).to receive(:store)

      ExchangeRateConverter::RATES_FILE = 'spec/support/rates.csv'
      ExchangeRateConverter.upload_rates_to_database
    end

    it 'should not upload a bad exchange rate file' do
      allow(Database).to receive(:store)

      expect(Database).not_to receive(:store)

      ExchangeRateConverter::RATES_FILE = 'spec/support/rates_bad.csv'
      expect {
        ExchangeRateConverter.upload_rates_to_database
      }.to raise_error(FileFormatError)
    end
  end

  describe '#convert_amount_rate' do
    it 'should convert with the rate of an existing date' do
      ExchangeRateConverter.send(:store_rate_for_date, '2016-01-01', 1.232)
      expect(ExchangeRateConverter.convert(10, '2016-01-01')).to eq 8.12
    end

    it 'should convert with the rate of the nearest previous date' do
      ExchangeRateConverter.send(:store_rate_for_date, '2015-12-30', 1.232)
      expect(ExchangeRateConverter.convert(10, '2016-01-01')).to eq 8.12
    end

    it 'should not convert dates previous to 2000' do
      expect{
        ExchangeRateConverter.convert(10, '1999-01-01')
      }.to raise_error(ArgumentError)
    end

    it 'should raise error if database is empty' do
      allow(Database).to receive(:read).and_return(nil)

      expect{
        ExchangeRateConverter.convert(10, '2015-01-01')
      }.to raise_error(RatesNotLoaded)
    end
  end
end