class PolicyDatatable < AjaxDatatablesRails::ActiveRecord

  extend Forwardable
  include GeneralMethods

  def_delegator :@view, :link_to

  def initialize(params, opts = {})
    @view = opts[:view_context]
    super
  end

  def view_columns
    # Declare strings in this format: ModelName.column_name
    # or in aliased_join_table.column_name format
    @view_columns ||= {
        id:               {source: "Policy.id"},
        transaction_type: {source: "Transaction.transaction_type"},
        name:             {source: "Customer.name"},
        status:           {source: "Policy.status"},
        coverage_type:    {source: "Policy.coverage_type"},
        effective:        {source: "Transaction.effective_date"},
        expiry:           {source: "Transaction.expiry_date"},
        vehicle:          {source: "Policy.vehicle"},
        billing_type:     {source: "Policy.billing_type"},
        vin:              {source: "Policy.vin"},
        reg_num:          {source: "Policy.reg_num"},
        broker_name:      {source: "Broker.name"},
        user_name:        {source: "User.name"},
        created_at:       {source: "Transaction.created_at"},
        snap_status:      {source: "Policy.snap_status"},
        quote_number:     {source: "Policy.quote_number"}
    }

  end

  def data
    records.map do |record|
      {
          id: link_to(record.id, Rails.application.routes.url_helpers.policy_detail_path(id: record.id), method: 'get'),
          transaction_type: get_transaction_type(record),
          name: record.name,
          status: record.status.capitalize,
          coverage_type: get_shortened_coverage_type(record),
          effective: record.effective_date.strftime("%b %-d, %Y"),
          expiry: get_expiry_date(record),
          vehicle: record.vehicle,
          billing_type: record.billing_type,
          vin: record.vin.upcase,
          reg_num: record.reg_num,
          broker_name: record.broker_name,
          user_name: record.user_name,
          created_at: record.created_at.strftime("%b %-d, %Y %R"),
          snap_status: record.snap_status,
          quote_number: record.quote_number,
          DT_RowId: record.id # This will automagically set the id attribute on the corresponding <tr> in the datatable
      }
    end
  end

  def get_raw_records

    query = Customer.joins(policies: [{transactions: :user}, :broker]).where(policies: {broker_id: [options[:broker_list]]}).select(
        "policies.id AS id,
         transactions.transaction_type AS transaction_type,
         customers.name AS name,
         policies.status AS status,
         policies.coverage_type AS coverage_type,
         transactions.effective_date AS effective_date,
         transactions.expiry_date AS expiry_date,
         policies.billing_type AS billing_type,
         policies.vehicle AS vehicle,
         policies.vin AS vin,
         policies.reg_num AS reg_num,
         brokers.name AS broker_name,
         users.name AS user_name,
         transactions.created_at AS created_at,
         policies.snap_status AS snap_status,
         policies.quote_number AS quote_number"
    )

    start_date_present = options[:start_date].present?
    end_date_present = options[:end_date].present?

    if options[:filter_by].present?
      if start_date_present and !end_date_present
        query = query.where("transactions.#{options[:filter_by]} >= ?",options[:start_date].beginning_of_day)
      elsif !start_date_present and end_date_present
        query = query.where("transactions.#{options[:filter_by]} <= ?",options[:end_date].end_of_day)
      elsif start_date_present and end_date_present
        query = query.where("transactions.#{options[:filter_by]} >= ? AND transactions.#{options[:filter_by]} <= ?",options[:start_date].beginning_of_day,options[:end_date].end_of_day)
      end
    end

    query
    # Policy.joins(:transactions, :customer).select("policies.*, transactions.*, customers.*")
  end

  def get_expiry_date(record)
    record.expiry_date.strftime("%b %-d, %Y") unless record.expiry_date.blank?
  end

  def get_shortened_coverage_type(record)
    if record.coverage_type.blank?
      ""
    else
      # if record.coverage_type === FULL_REPLACEMENT
      #   'FR'
      # elsif record.coverage_type === LIMITED_DEPRECIATION
      #   'LD'
      # end
      record.coverage_type
    end
  end

  def get_transaction_type(record)
    if record.transaction_type === "new"
      "New Policy"
    else
      record.transaction_type.capitalize
    end
  end

end