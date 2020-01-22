require 'pdf_forms'

class PrintCancellationCertificate < FillablePdfForm

  include CancellationMethods
  include ActionView::Helpers::NumberHelper

  def initialize(policy,certificate_type)
    @policy = policy
    @certificate_type = certificate_type
    super()
  end

  protected

  def fill_out

    # GET ALL RELATED MODELS FROM @policy
    customer = @policy.customer
    broker = @policy.broker
    new_transaction = @policy.transactions.find_by(transaction_type: "new")
    cancelled_transaction = @policy.transactions.find_by(transaction_type: CANCELLED)
    user = new_transaction.user

    # VARIABLES
    co_insured_full_name = @policy.co_insured_first_name
    if @policy.co_insured_first_name.present? and @policy.co_insured_last_name.present?
      co_insured_full_name += " #{@policy.co_insured_last_name}"
    end

    lessor_name = @policy.lessor_name
    coverage_type = @policy.coverage_type
    oem_body_parts = @policy.oem_body_parts
    dealer_fee = new_transaction.dealer_fee

    total_premium = new_transaction.total_premium
    earned_premium = total_premium - cancelled_transaction.total_premium
    unpaid_balance = @policy.unpaid_balance
    end_result = total_premium - earned_premium - unpaid_balance

    # ================================================================================================================ #

    ## TOP
    fill :policy_id, @policy.id

    # ---------------------------------------------------------------------------------------------------------------- #

    ## APPLICANT - INSURED
    fill :full_name, customer.name

    if co_insured_full_name.present?
      fill :co_insured_full_name, co_insured_full_name
      fill :co_insured_full_name_label, "Co-Insured's Name"
    end

    if lessor_name.present?
      fill :lessor_name_label, "Lease Company Name"
      fill :lessor_name, lessor_name
    end
    fill :address, customer.address
    fill :city_province_postal_code, "#{customer.city}, #{customer.province}, #{customer.postal_code}"

    # -----------------------------------------------------------------------------------------------------------------#

    ## BROKER
    fill :broker_name, broker.name
    fill :broker_phone, format_phone(broker.phone)
    fill :selling_agent, user.name

    if [OUT_OF_PROVINCE,PRIVATE_SALE].include?(@policy.dealer_category)
      fill :dealer, "N/A"
    else
      fill :dealer, @policy.dealer
    end

    # -----------------------------------------------------------------------------------------------------------------#

    ## DESCRIBED VEHICLE
    fill :vehicle, "#{@policy.model_year} #{@policy.make} #{@policy.model}"
    fill :vin, @policy.vin.upcase
    fill :reg_num, @policy.reg_num.to_s
    fill :purchase_date, @policy.purchase_date.strftime("%b %-d, %Y")
    fill :vehicle_price, number_to_currency(@policy.vehicle_price, precision: 0)
    fill :odometer, "#{number_with_delimiter(@policy.odometer, delimiter: ',')} km"
    fill :driver_factor, '%.3f' % @policy.driver_factor
    fill :use_rate_class, @policy.use_rate_class[0,3]

    # -----------------------------------------------------------------------------------------------------------------#

    ## COVERAGE TYPE AND TERM
    fill :coverage_type, coverage_type
    fill :effective_date, new_transaction.effective_date.strftime("%b %-d, %Y")
    fill :policy_term, @policy.policy_term
    fill :expiry_date, new_transaction.expiry_date.strftime("%b %-d, %Y")

    if oem_body_parts === YES_2_YEARS || oem_body_parts === YES_3_YEARS
      fill :oem_body_parts, "Yes - until "+ (new_transaction.effective_date + (oem_body_parts.partition(' - ').last[0].to_i).years).strftime("%b %-d, %Y")
    else
      fill :oem_body_parts, oem_body_parts
    end

    # -----------------------------------------------------------------------------------------------------------------#

    ## TRANSACTION DETAILS
    fill :transaction_reason, cancelled_transaction.transaction_reason
    fill :cancellation_effective_date, cancelled_transaction.effective_date.strftime("%b %-d, %Y")
    fill :agent_comments, cancelled_transaction.agent_comments

    # -----------------------------------------------------------------------------------------------------------------#

    ## PREMIUMS AND FEES
    coverage_type_premium_label = "Vehicle #{coverage_type} Insurance Premium: #{DOLLAR_LABEL}"
    fill :coverage_type_premium_label, coverage_type_premium_label
    fill :premium, number_with_precision(new_transaction.coverage_premium + new_transaction.oem_body_parts_premium, precision: 2, delimiter: ',')

    if oem_body_parts === (YES_3_YEARS or YES_2_YEARS)
      fill :oem_body_parts_premium_label, OEM_BODY_PARTS_INCLUDED_LABEL
      fill :oem_body_parts_included, "Included"
    end

    fill :admin_fee_label, POLICY_FEE_LABEL
    fill :admin_fee, number_with_precision(new_transaction.admin_fee + new_transaction.finance_admin_fee, precision: 2, delimiter: ',')

    if dealer_fee != 0
      fill :dealer_fee_label, DEALER_FEE_LABEL
      fill :dealer_fee, number_with_precision(dealer_fee, precision: 2, delimiter: ',')
    end

    fill :total_premium_label, TOTAL_PREMIUM_LABEL
    fill :total_premium, number_with_precision(total_premium, precision: 2, delimiter: ',')

    fill :less_earned_premiums_and_fees_label, EARNED_PREMIUM_LABEL
    fill :less_earned_premiums_and_fees, number_with_precision(earned_premium, precision: 2, delimiter: ',')

    unpaid_balance_label = UNPAID_BALANCE_LABEL
    if (@policy.billing_type === BROKER_BILL) and (unpaid_balance > 0)
      unpaid_balance_label = UNPAID_NSF_BALANCE_LABEL
    end

    fill :less_unpaid_balance_label, unpaid_balance_label
    fill :less_unpaid_balance, number_with_precision(unpaid_balance, precision: 2, delimiter: ',')

    refund_owed_label = REFUND_OWED_LABEL
    if end_result < 0
      refund_owed_label = AMOUNT_OWED_LABEL
    elsif @policy.status === TRANSFERRED
      refund_owed_label = CREDIT_OWED_LABEL
    end

    fill :refund_owed_label, refund_owed_label
    fill :refund_owed, number_with_precision(end_result.abs, precision: 2, delimiter: ',')

    # -----------------------------------------------------------------------------------------------------------------#

    ## SIGNATURES
    fill :insured_signature_label, "Applicant's Signature"

    signature = 'X'
    if @certificate_type === "insured"
      signature = '(Signature not required)'
    end

    fill :insured_signature, signature
    if co_insured_full_name.present?
      fill :co_insured_signature_label, "Co-Applicant's Signature"
      fill :co_insured_signature, signature
    end

    certificate_type_printed = "BROKER'S COPY"
    if @certificate_type === "insured"
      certificate_type_printed = "INSURED'S COPY"
    end

    fill :certificate_type, certificate_type_printed

  end

end