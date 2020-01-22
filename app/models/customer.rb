class Customer < ApplicationRecord

  include CustomValidations
  has_many :policies

  has_paper_trail on: [:update]

  before_save :normalize_blank_values

  #step 3
  validate :insured_type_validations
  validate :first_name_validations
  validate :last_name_validations
  validate :full_name_validations
  validate :address_validations
  validate :city_validations
  validate :province_validations
  validate :postal_code_validations
  validate :combined_validations
  validate :phone_validations
  validate :email_validations

  def self.to_csv(options = {})
    desired_columns = ["policy_id","policy_status","transaction_id","transaction_type","first_name","last_name","coverage_type", "policy_term",
                       "oem_body_parts","billing_type","financing_term","snap_status","effective_date","expiry_date",
                       "transaction_reason","transaction_date","model_year","make","model","vehicle_price","vin",
                       "registration_number","dealer_category","dealer","coverage_premium","oem_body_parts_premium",
                       "dealer_fee","policy_fee","finance_admin_fee","total_premium","unpaid_balance","transferred_premium","broker_name","agent_name",
                       "agent_comments"]
    CSV.generate(options) do |csv|
      csv << desired_columns
      all.each do |t|
        row_vals = t.attributes.values_at(*desired_columns)
        if row_vals[desired_columns.index("transaction_type")] === CANCELLED
          row_vals.each_with_index do |row,index|
            if row.is_a? Float and row != 0
              row_vals[index] = -row
            end
          end
        end
        transaction_date_index = desired_columns.index("transaction_date")
        row_vals[transaction_date_index] = row_vals[transaction_date_index].in_time_zone('America/Los_Angeles').strftime("%b %-d, %Y %R")
        csv << row_vals
      end
    end
  end

end
