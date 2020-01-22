class ModificationsController < ApplicationController

  before_action :check_employment, only: :index

  def index
    @new_transaction = @policy.transactions.find_by(transaction_type: "new")
    @cancelled_transaction = @policy.transactions.find_by(transaction_type: CANCELLED)
  end

  private

    def check_employment
      @policy = Policy.find(params[:id])
      access_denied_broker(@policy.broker_id)
    end

end
