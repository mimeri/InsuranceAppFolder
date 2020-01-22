class NewapplicationDatatable < AjaxDatatablesRails::ActiveRecord

  extend Forwardable

  def_delegator :@view, :link_to

  def initialize(params, opts = {})
    @view = opts[:view_context]
    super
  end

  def view_columns
    # Declare strings in this format: ModelName.column_name
    # or in aliased_join_table.column_name format
    @view_columns ||= {
        # id:             {source: "Newapplication.id"},
        name:           {source: "Newapplication.name"},
        status:         {source: "Newapplication.status"},
        coverage_type:  {source: "Newapplication.coverage_type"},
        vehicle:        {source: "Newapplication.vehicle"},
        billing_type:   {source: "Newapplication.billing_type"},
        vin:            {source: "Newapplication.vin"},
        reg_num:        {source: "Newapplication.reg_num"},
        broker_name:    {source: "Broker.name"},
        user_name:      {source: "User.name"},
        updated_at:     {source: "Newapplication.updated_at"},
        created_at:     {source: "Newapplication.created_at"}
    }
  end

  def data
    records.map do |record|
      {
          name: link_to(get_name(record), Rails.application.routes.url_helpers.recall_application_path(id: record.id), method: 'post', data: {turbolinks: false}),
          status: record.status,
          coverage_type: record.coverage_type,
          vehicle: record.vehicle,
          billing_type: get_shortened_billing_type(record),
          vin: record.vin,
          reg_num: record.reg_num,
          broker_name: record.broker_name,
          user_name: record.user_name,
          updated_at: record.updated_at.strftime("%b %-d, %Y %R"),
          created_at: record.created_at.strftime("%b %-d, %Y %R")
      }
    end
  end

  def get_name(record)
    if record.name.present?
      record.name
    else
      "(Blank)"
    end
  end

  def get_raw_records
    query = Newapplication.joins(:user, :broker).where(broker_id: [options[:broker_list]]).select(
        "newapplications.id AS id,
         newapplications.name AS name,
         newapplications.status AS status,
         newapplications.coverage_type AS coverage_type,
         newapplications.vehicle AS vehicle,
         newapplications.billing_type AS billing_type,
         newapplications.vin AS vin,
         newapplications.reg_num AS reg_num,
         brokers.name AS broker_name,
         users.name AS user_name,
         newapplications.updated_at AS updated_at,
         newapplications.created_at AS created_at"
    )

    start_date_present = options[:start_date].present?
    end_date_present = options[:end_date].present?

    if options[:filter_by].present?
      if start_date_present and !end_date_present
        query = query.where("newapplications.#{options[:filter_by]} >= ?",options[:start_date].beginning_of_day)
      elsif !start_date_present and end_date_present
        query = query.where("newapplications.#{options[:filter_by]} <= ?",options[:end_date].end_of_day)
      elsif start_date_present and end_date_present
        query = query.where("newapplications.#{options[:filter_by]} >= ? AND newapplications.#{options[:filter_by]} <= ?",options[:start_date].beginning_of_day,options[:end_date].end_of_day)
      end
    end

    query
  end

  def get_shortened_billing_type(record)
    if record.billing_type === BROKER_BILL
      'Broker'
    elsif record.billing_type === DIRECT_BILL
      'Direct'
    end
  end

end
