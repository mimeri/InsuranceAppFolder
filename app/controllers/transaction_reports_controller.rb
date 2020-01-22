class TransactionReportsController < ApplicationController

  def new
    @brokers = Broker.where(id: [get_broker_id_list])
  end

  def create
    @transaction_report = TransactionReport.new(transaction_report_params.merge(current_user: current_user))
    if @transaction_report.valid?
      if @transaction_report.update_table_check === '1'
        UpdateSnapStatusJob.perform_now
      end
      start_date, end_date = @transaction_report.set_date_range
      transactions = transaction_query(@transaction_report.broker_id, @transaction_report.attribute_filter, start_date, end_date, @transaction_report.keep_void_check)
      respond_to do |format|
        format.csv { send_data transactions.to_csv, filename: 'transaction_report.csv' }
      end
    else
      flash[:danger] = get_error_message(@transaction_report)
      redirect_to transaction_reports_path, method: :get
    end
  end

  private

    def transaction_report_params
      params.require(:transaction_report).permit(:broker_id, :attribute_filter, :date_range_type, :start_custom_date, :end_custom_date, :update_table_check, :keep_void_check)
    end

    def get_error_message(object)
      error_array = []
      object.errors.full_messages.each do |e|
        error_array << e
      end
      error_array.join("<br/>")
    end

    def transaction_query(broker_id,filter_by,start_date,end_date,keep_void_check)

      remove_void_string = ""
      if keep_void_check === '0'
        remove_void_string = " AND policies.status NOT IN ('#{VOID}')"
      end

      query = Customer.joins(policies: [{transactions: :user}, :broker]).where(
          "brokers.id IN (?)"+remove_void_string,broker_id).order("transactions.created_at ASC").select(
          "policies.id AS policy_id,
           policies.status AS policy_status,
           transactions.id AS transaction_id,
           transactions.transaction_type AS transaction_type,
           customers.first_name AS first_name,
           customers.last_name AS last_name,
           policies.coverage_type AS coverage_type,
           policies.policy_term AS policy_term,
           policies.oem_body_parts AS oem_body_parts,
           policies.billing_type AS billing_type,
           policies.financing_term AS financing_term,
           policies.snap_status AS snap_status,
           transactions.effective_date AS effective_date,
           transactions.expiry_date AS expiry_date,
           transactions.transaction_reason AS transaction_reason,
           transactions.created_at AS transaction_date,
           transactions.created_at AS created_at,
           policies.model_year AS model_year,
           policies.make AS make,
           policies.model AS model,
           policies.vehicle_price AS vehicle_price,
           policies.vin AS vin,
           policies.reg_num AS registration_number,
           policies.dealer_category AS dealer_category,
           policies.dealer AS dealer,
           transactions.coverage_premium AS coverage_premium,
           transactions.oem_body_parts_premium AS oem_body_parts_premium,
           transactions.dealer_fee AS dealer_fee,
           transactions.admin_fee AS policy_fee,
           transactions.finance_admin_fee AS finance_admin_fee,
           transactions.total_premium AS total_premium,
           policies.unpaid_balance AS unpaid_balance,
           policies.transferred_premium AS transferred_premium,
           brokers.name AS broker_name,
           users.name AS agent_name,
           transactions.agent_comments AS agent_comments")

      start_date_present = start_date.present?
      end_date_present = end_date.present?

      if filter_by.present?
        if start_date_present and !end_date_present
          query = query.where("transactions.#{filter_by} >= ?",start_date).order("transactions.#{filter_by} ASC")
        elsif !start_date_present and end_date_present
          query = query.where("transactions.#{filter_by} <= ?",end_date).order("transactions.#{filter_by} ASC")
        elsif start_date_present and end_date_present
          query = query.where("transactions.#{filter_by} >= ? AND transactions.#{filter_by} <= ?",start_date,end_date).order("transactions.#{filter_by} ASC")
        end
      end

      query
    end
end



