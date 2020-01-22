class QuickquotesController < ApplicationController

  def new
    @quickquote = Quickquote.new
  end

  def create
    @quickquote = Quickquote.new quickquote_params.merge(validate_bool: true)
  end

  private

    def quickquote_params
      params.require(:quickquote).permit(:model_year,
                                         :vehicle_price,
                                         :dealer_category,
                                         :coverage_type,
                                         :policy_term,
                                         :oem_body_parts,
                                         :billing_type,
                                         :financing_term,
                                         :transferred_premium)
    end

end
