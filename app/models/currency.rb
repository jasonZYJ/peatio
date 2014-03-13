class Currency < Settingslogic
  def self.makeup(one, two)
    codes = self.codes
    codes[one.to_sym] ^ codes[two.to_sym]
  end

  def self.coin_urls
    @coins ||= extract_coin_property :rpc
  end

  def self.codes
    # {:currency => :currency_code, ...}
    @codes ||= self.currencies.symbolize_keys
  end

  def self.trade_config(code)
    @trade_configs ||= self.trades.map do |d|
      {d["name"] => d} 
    end.inject do 
      |sum, x| sum.merge x 
    end.symbolize_keys

    @trade_configs[code.to_sym].symbolize_keys.tap do |conf|
      conf[:bid][:fee] = conf[:bid][:fee].to_d / 10000.to_d
      conf[:ask][:fee] = conf[:ask][:fee].to_d / 10000.to_d
    end
  end

  def self.find_or_create_wallets_from_config
    extract_coin_property(:hdwallet) do |currency, hex|
      query = { serialized_address: hex, currency: currencies[currency] }
      HDWallet.where(query).first_or_create
    end
  end

  source "#{Rails.root}/config/currency.yml"
  namespace Rails.env
  suppress_errors Rails.env.production?

  private

  def extract_coin_property(property)
    HashWithIndifferentAccess[
      self.coins.map do |k, v|
        value = v[property.to_s]
        value = yield(k, value) if block_given?
        [k, value]
      end
    ]
  end
end
