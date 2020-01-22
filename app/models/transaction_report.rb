class TransactionReport

  include ActiveModel::Model

  include GeneralMethods

  DATE_RANGE_TYPES = ["Current month","Last month","Current year","Last year","Today","Custom Date Range"]

  attr_accessor :current_user,
                :broker_id,
                :attribute_filter,
                :date_range_type,
                :start_custom_date,
                :end_custom_date,
                :update_table_check,
                :keep_void_check

  validates :broker_id, broker_id: true
  validate  :attribute_filter_validations
  validate  :date_range_type_validations
  validate  :custom_date_validations
  validates :update_table_check, presence: true, inclusion: { in: ['0','1'] }
  validates :keep_void_check, presence: true, inclusion: { in: ['0','1'] }

  def set_date_range
    case date_range_type
    when "Current month"
      start_date = Date.current.at_beginning_of_month
      end_date = Date.current
    when "Last month"
      start_date = Date.current.ago(1.month).beginning_of_month
      end_date = Date.current.ago(1.month).end_of_month
    when "Current year"
      start_date = Date.current.beginning_of_year
      end_date = Date.current
    when "Last year"
      start_date = Date.current.ago(1.year).beginning_of_year
      end_date = Date.current.ago(1.year).end_of_year
    when "Today"
      start_date = Date.current
      end_date = Date.current
    when "Custom Date Range"
      start_date = populate_if_date(start_custom_date)
      end_date = populate_if_date(end_custom_date)
    else
      start_date = nil
      end_date = nil
    end
    if attribute_filter === "created_at"
      start_date = start_date.beginning_of_day unless start_date.blank?
      end_date = end_date.end_of_day unless end_date.blank?
    end
    [start_date, end_date]
  end

  private

    def attribute_filter_validations
      if attribute_filter.present?
        unless is_valid_transaction_filter(attribute_filter)
          errors.add(:attribute_filter, IS_INVALID_REPORT)
        end
      end
    end

    def date_range_type_validations
      if attribute_filter.present?
        if date_range_type.blank?
          errors.add(:date_range_type, CANT_BE_BLANK_REPORT)
        else
          if DATE_RANGE_TYPES.include?(date_range_type) === false
            errors.add(:date_range_type, IS_INVALID_REPORT)
          end
        end
      end
    end

    def custom_date_validations
      if date_range_type === "Custom Date Range"
        if start_custom_date.blank? and end_custom_date.blank?
          errors.add(:base, "Error. Start and end dates can't both be blank.")
        end
        [start_custom_date,end_custom_date].each do |custom_date|
          if custom_date.present? and !is_date(custom_date)
            errors.add(:base, "Inputted dates are invalid. #{REPORT}")
          end
        end
      end
    end

end
