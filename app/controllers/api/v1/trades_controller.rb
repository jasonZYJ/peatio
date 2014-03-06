module Api
  module V1
    class TradesController < BaseController
      def show
        if params[:since]
          @trades = Global[params[:id]].since_trades(params[:since])
        elsif params[:hours]
          @trades = Global[params[:id]].trades_by_hours(params[:hours])
        else
          @trades = Global[params[:id]].trades.reverse
        end
      end
    end
  end
end

