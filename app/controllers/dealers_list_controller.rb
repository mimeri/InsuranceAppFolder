class DealersListController < ApplicationController
  def index
    search_string = params[:term].upcase
    @dealers = Policy.order(:dealer).where("dealer like ?", "%#{search_string}%")
    render json: @dealers.map(&:dealer).uniq
  end
end
