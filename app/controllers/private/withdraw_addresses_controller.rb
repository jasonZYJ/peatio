module Private
  class WithdrawAddressesController < BaseController
    respond_to :json
    def index
       respond_with current_user.withdraw_addresses.with_category(params[:currency])
    end

    def destroy
      WithdrawAddress.where(
        :id => params[:id],
        :is_locked => false,
        :account_id => current_user.accounts).destroy_all
      head :ok
    end
  end
end

