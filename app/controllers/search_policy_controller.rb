class SearchPolicyController < ApplicationController

  def index
    @filter_by = params[:filter_by] unless (is_valid_transaction_filter(params[:filter_by]) === false)
    @start_date = populate_if_date(params[:start_date])
    @end_date = populate_if_date(params[:end_date])

    respond_to do |format|
      format.html
      format.json { render json: PolicyDatatable.new(params, view_context: view_context, broker_list: get_broker_id_list, filter_by: @filter_by, start_date: @start_date, end_date: @end_date)}
    end
  end

  def filter
    filter_by = date_filter_params["type"]
    start_date = date_filter_params["start"]
    end_date = date_filter_params["end"]

    if is_valid_transaction_filter(filter_by) === false
      filter_by = nil
    end

    invalid_dates_bool = ((!is_date(start_date) or !is_date(end_date)) or (start_date.blank? and end_date.blank?))

    if filter_by.present? and invalid_dates_bool
      flash[:danger] = "Error, failed to apply filter, please recheck your settings"
    end

    if filter_by.blank? or invalid_dates_bool
      redirect_to search_policy_index_path
    else
      redirect_to search_policy_index_path(filter_by: filter_by, start_date: start_date, end_date: end_date)
    end
  end

  def update_table
    UpdateSnapStatusJob.perform_now
    flash[:success] = "All Transactions are now up to date"
    redirect_to search_policy_index_path
  end

  private

  def date_filter_params
    params.require(:search_policy_date_filter).permit(:type, :start, :end)
  end

end
