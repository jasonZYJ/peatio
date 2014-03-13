require 'spec_helper'

describe Global do
  before { Rails.cache.clear }
  let(:global) { Global['cnybtc'] }

  describe Global, '#update_ticker' do
    it "expect zero ticker in Rails.cache" do
      [:low, :high, :last, :volume, :buy, :sell].each do |key|
        expect(global.ticker[key]).to be_zero
      end
    end

    it "expect store to redis" do
      create(:order_ask)
      create(:order_bid)
      create(:trade)
      [:low, :high, :last, :volume, :buy, :sell].each do |key|
        expect(global.ticker[key]).not_to be_zero
      end
    end
  end

  describe Global, '#update_asks' do
    it "expect empty asks in Rails.cache" do
      expect(global.asks).to be_empty
    end

    it "expect store asks in Rails.cache" do
      create(:order_ask)
      expect(global.asks).to_not be_empty
    end
  end

  describe Global, '#update_trades' do
    it "expect store trades in Rails.cache" do
      create(:trade, currency: 'cnybtc')
      expect(global.trades).to_not be_empty
    end
  end
end

