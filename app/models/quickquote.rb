require 'rest-client'
require 'bigdecimal'
require 'bigdecimal/util'

class Quickquote < ApplicationRecord

  include ActiveModel::Model
  include RateCalculation
  include CustomValidations
  include StringTemplates

  attr_accessor :model_year,
                :vehicle_price,
                :dealer_category,
                :dealer,
                :coverage_type,
                :policy_term,
                :oem_body_parts,
                :billing_type,
                :financing_term,
                :validate_bool,
                :transferred_premium

  def premium_amount
    @premium_amt ||= calculate_premium(coverage_type,model_year,policy_term,vehicle_price,dealer_category)
  end

  def oem
    @oem_amt ||= calculate_oem_premium(oem_body_parts,vehicle_price)
  end

  def dealer_fees
    @dealer_fees ||= get_dealer_fees(dealer_category)
  end

  def admin_fees
    @admin_fees ||= get_admin_fees(dealer_category) + get_finance_admin_fees(billing_type)
  end

  def total_premiums_and_fees
    @total_premiums_and_fees ||= (premium_amount + oem + dealer_fees + admin_fees).round(2)
  end

  def get_transferred_premium
    transferred_premium.to_f.round(2)
  end

  def total
    @total ||= (total_premiums_and_fees - get_transferred_premium).round(2)
  end

  def amount_financed
    @amount_financed ||= calculate_amount_financed(billing_type,total)
  end

  def monthly_payment
    if billing_type === BROKER_BILL
      nil
    elsif billing_type === DIRECT_BILL
      xml_string = quote_import_placeholder_xml(financing_term,amount_financed)
      hash = snap_api_call(QUOTE_IMPORT_URL,xml_string)
      if quote_import_is_successful(hash)
        hash["QuoteResponse"]["QuoteInformation"]["InstallmentAmount"].to_f.round(2)
      else
        hash["QuoteResponse"]["Errors"]["string"]
      end
    end
  end

  def owed
    total - amount_financed
  end

  with_options if: -> {self.validate_bool === true} do
    validate :model_year_validations
    validate :vehicle_price_validations
    validate :dealer_category_validations
    validates :coverage_type, presence: true, inclusion: { in: [FULL_REPLACEMENT,LIMITED_DEPRECIATION] }
    validate :policy_term_validations
    validate :oem_validations
    validate :billing_type_validations
    validate :financing_term_validations
    validate :monthly_payment_validations
  end

end
