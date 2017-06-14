require 'spec_helper'
require_relative '../database'

describe Database do

  describe '#store' do
    it 'should store a value under a given key' do
      Database.store(1, 100)

      expect(Database.read(1)).to eq 100
    end
  end
end