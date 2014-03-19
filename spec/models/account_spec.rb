require 'spec_helper'

describe Account do
  subject { create(:account, locked: "10.0".to_d, balance: "10.0") }

  it { expect(subject.amount).to be_d '20' }
  it { expect(subject.sub_funds("1.0".to_d).balance).to eql "9.0".to_d }
  it { expect(subject.plus_funds("1.0".to_d).balance).to eql "11.0".to_d }
  it { expect(subject.unlock_funds("1.0".to_d).locked).to eql "9.0".to_d }
  it { expect(subject.unlock_funds("1.0".to_d).balance).to eql "11.0".to_d }
  it { expect(subject.lock_funds("1.0".to_d).locked).to eql "11.0".to_d }
  it { expect(subject.lock_funds("1.0".to_d).balance).to eql "9.0".to_d }

  it { expect(subject.unlock_and_sub_funds('1.0'.to_d, locked: '1.0'.to_d).balance).to be_d '10' }
  it { expect(subject.unlock_and_sub_funds('1.0'.to_d, locked: '1.0'.to_d).locked).to be_d '9' }

  it { expect(subject.sub_funds("0.1".to_d).balance).to eql "9.9".to_d }
  it { expect(subject.plus_funds("0.1".to_d).balance).to eql "10.1".to_d }
  it { expect(subject.unlock_funds("0.1".to_d).locked).to eql "9.9".to_d }
  it { expect(subject.unlock_funds("0.1".to_d).balance).to eql "10.1".to_d }
  it { expect(subject.lock_funds("0.1".to_d).locked).to eql "10.1".to_d }
  it { expect(subject.lock_funds("0.1".to_d).balance).to eql "9.9".to_d }

  it { expect(subject.unlock_and_sub_funds('0.1'.to_d, locked: '1.0'.to_d).balance).to be_d '10.9' }
  it { expect(subject.unlock_and_sub_funds('0.1'.to_d, locked: '1.0'.to_d).locked).to be_d '9' }

  it { expect(subject.sub_funds("10.0".to_d).balance).to eql "0.0".to_d }
  it { expect(subject.plus_funds("10.0".to_d).balance).to eql "20.0".to_d }
  it { expect(subject.unlock_funds("10.0".to_d).locked).to eql "0.0".to_d }
  it { expect(subject.unlock_funds("10.0".to_d).balance).to eql "20.0".to_d }
  it { expect(subject.lock_funds("10.0".to_d).locked).to eql "20.0".to_d }
  it { expect(subject.lock_funds("10.0".to_d).balance).to eql "0.0".to_d }

  it { expect{subject.sub_funds("11.0".to_d)}.to raise_error }
  it { expect{subject.lock_funds("11.0".to_d)}.to raise_error }
  it { expect{subject.unlock_funds("11.0".to_d)}.to raise_error }

  it { expect{subject.unlock_and_sub_funds('1.1'.to_d, locked: '1.0'.to_d)}.to raise_error }

  it { expect{subject.sub_funds("-1.0".to_d)}.to raise_error }
  it { expect{subject.plus_funds("-1.0".to_d)}.to raise_error }
  it { expect{subject.lock_funds("-1.0".to_d)}.to raise_error }
  it { expect{subject.unlock_funds("-1.0".to_d)}.to raise_error }
  it { expect{subject.sub_funds("0".to_d)}.to raise_error }
  it { expect{subject.plus_funds("0".to_d)}.to raise_error }
  it { expect{subject.lock_funds("0".to_d)}.to raise_error }
  it { expect{subject.unlock_funds("0".to_d)}.to raise_error }

  it "expect to set reason" do
    subject.plus_funds("1.0".to_d)
    expect(subject.last_version.reason.to_sym).to eql Account::UNKNOWN
  end

  it "expect to set ref" do
    ref = stub(:id => 1)

    subject.plus_funds("1.0".to_d, ref: ref)

    expect(subject.last_version.modifiable_id).to eql 1
    expect(subject.last_version.modifiable_type).to eql Mocha::Mock.name
  end

  describe "double operation" do
    let(:strike_volume) { "10.0".to_d }
    let(:account) { create(:account) }

    it "expect double operation funds" do
      expect do
        account.plus_funds(strike_volume, reason: Account::STRIKE_ADD)
        account.sub_funds(strike_volume, reason: Account::STRIKE_FEE)
      end.to_not change{account.balance}
    end

    it "expect double operation funds to add versions" do
      expect do
        account.plus_funds(strike_volume, reason: Account::STRIKE_ADD)
        account.sub_funds(strike_volume, reason: Account::STRIKE_FEE)
      end.to change{account.versions.size}.from(0).to(2)
    end
  end

  describe "#versions" do
    let(:account) { create(:account) }

    context 'when account add funds' do
      subject { account.plus_funds("10".to_d, reason: Account::WITHDRAW).last_version }

      it { expect(subject.reason.withdraw?).to be_true }
      it { expect(subject.locked).to be_d "0" }
      it { expect(subject.balance).to be_d "10" }
      it { expect(subject.amount).to be_d "110" }
      it { expect(subject.fee).to be_d "0" }
      it { expect(subject.fun).to eq 'plus_funds' }
    end

    context 'when account add funds with fee' do
      subject { account.plus_funds("10".to_d, fee: '1'.to_d, reason: Account::WITHDRAW).last_version }

      it { expect(subject.reason.withdraw?).to be_true }
      it { expect(subject.locked).to be_d "0" }
      it { expect(subject.balance).to be_d "10" }
      it { expect(subject.amount).to be_d "110" }
      it { expect(subject.fee).to be_d "1" }
      it { expect(subject.fun).to eq 'plus_funds' }
    end

    context 'when account sub funds' do
      subject { account.sub_funds("10".to_d, reason: Account::WITHDRAW).last_version }
      it { expect(subject.reason.withdraw?).to be_true }
      it { expect(subject.locked).to be_d "0" }
      it { expect(subject.balance).to be_d "-10" }
      it { expect(subject.amount).to be_d "90" }
      it { expect(subject.fee).to be_d "0" }
      it { expect(subject.fun).to eq 'sub_funds' }
    end

    context 'when account sub funds with fee' do
      subject { account.sub_funds("10".to_d, fee: '1'.to_d, reason: Account::WITHDRAW).last_version }
      it { expect(subject.reason.withdraw?).to be_true }
      it { expect(subject.locked).to be_d "0" }
      it { expect(subject.balance).to be_d "-10" }
      it { expect(subject.amount).to be_d "90" }
      it { expect(subject.fee).to be_d "1" }
      it { expect(subject.fun).to eq 'sub_funds' }
    end

    context 'when account lock funds' do
      subject { account.lock_funds("10".to_d, reason: Account::WITHDRAW).last_version }
      it { expect(subject.reason.withdraw?).to be_true }
      it { expect(subject.locked).to be_d "10" }
      it { expect(subject.balance).to be_d "-10" }
      it { expect(subject.amount).to be_d "100.0" }
    end

    context 'when account unlock funds' do
      let(:account) { create(:account, locked: "10".to_d) }
      subject { account.unlock_funds("10".to_d, reason: Account::WITHDRAW).last_version }
      it { expect(subject.reason.withdraw?).to be_true }
      it { expect(subject.locked).to be_d "-10" }
      it { expect(subject.balance).to be_d "10" }
      it { expect(subject.amount).to be_d "110" }
    end

    context 'when account unlock and sub funds' do
      let(:account) { create(:account, balance: '10'.to_d, locked: "10".to_d) }
      subject { account.unlock_and_sub_funds("10".to_d, locked: "10".to_d, reason: Account::WITHDRAW).last_version }
      it { expect(subject.reason.withdraw?).to be_true }
      it { expect(subject.locked).to be_d "-10" }
      it { expect(subject.balance).to be_d "0" }
      it { expect(subject.amount).to be_d "10.0" }
      it { expect(subject.fee).to be_d "0" }
      it { expect(subject.fun).to eq 'unlock_and_sub_funds' }
    end

    context 'when account unlock and sub funds with fee' do
      let(:account) { create(:account, balance: '10'.to_d, locked: "10".to_d) }
      subject { account.unlock_and_sub_funds("10".to_d, fee: '1'.to_d, locked: "10".to_d, reason: Account::WITHDRAW).last_version }
      it { expect(subject.reason.withdraw?).to be_true }
      it { expect(subject.locked).to be_d "-10" }
      it { expect(subject.balance).to be_d "0" }
      it { expect(subject.amount).to be_d "10.0" }
      it { expect(subject.fee).to be_d "1" }
      it { expect(subject.fun).to eq 'unlock_and_sub_funds' }
    end
  end

  describe "#examine" do
    let(:account) { create(:account, locked: "0.0".to_d, balance: "0.0") }
    before do
      account.plus_funds("100.0".to_d)
      account.sub_funds("1.0".to_d)
      account.plus_funds("12.0".to_d)
      account.lock_funds("12.0".to_d)
      account.unlock_funds("1.0".to_d)
      account.lock_funds("1.0".to_d)
      account.lock_funds("1.0".to_d)
    end

    it "should be examine success" do
      expect(account.examine).to be_true
    end

    it "should be examine error whit hack account" do
      account.update_attribute(:balance, 5000.to_d)
      expect(account.examine).to be_false
    end

    it "should be examine error whit hack account version" do
      account.versions.load.sample.update_attribute(:amount, 50.to_d)
      expect(account.examine).to be_false
    end
  end

  describe "gen_payment_address" do
    let(:account) { create(:account_btc) }
    before { Currency.find_or_create_wallets_from_config }

    it 'gets it from HD wallet' do
      address = create(:payment_address)
      HDWallet.expects(:next_address).with(account.currency_value).returns(address)
      expect(account.gen_payment_address).to eq(address)
    end

    it 'declare ownership of the generated address' do
      payment_address = nil
      expect {
        payment_address = account.gen_payment_address
      }.to change(account.payment_addresses, :count).by(1)

      expect(payment_address.account).to eq account
    end
  end

  describe "payment_address" do
    let(:account) { create(:account_btc) }
    before { Currency.find_or_create_wallets_from_config }

    context 'when there is no address associated with the account' do
      it 'generates a payment address' do
        expect {
          account.payment_address
        }.to change(PaymentAddress, :count).by(1)
      end
    end

    context 'when there are addresses associated with the account' do
      let(:address) { create(:payment_address) }

      before do
        account.payment_addresses << address
      end

      it 'uses the last address if it does not have any transaction associated with it' do
        payment_address = nil
        expect {
          payment_address = account.payment_address
        }.to_not change(PaymentAddress, :count).by(1)

        expect(payment_address).to eq(address)
      end

      it 'generates a payment address if last address is used' do
        address.transactions << PaymentTransaction.new(address: address.address)
        expect {
          account.payment_address
        }.to change(PaymentAddress, :count).by(1)
      end
    end
  end
end
