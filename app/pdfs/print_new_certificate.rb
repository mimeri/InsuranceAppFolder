require 'pdf_forms'

class PrintNewCertificate < FillablePdfForm

  include StringFunctions
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
    user = new_transaction.user

    # VARIABLES
    co_insured_full_name = @policy.co_insured_first_name
    if @policy.co_insured_first_name.present? and @policy.co_insured_last_name.present?
      co_insured_full_name += " #{@policy.co_insured_last_name}"
    end

    lessor_name = @policy.lessor_name
    coverage_type = @policy.coverage_type
    oem_body_parts = @policy.oem_body_parts
    payment_method = @policy.payment_method
    dealer_fee = new_transaction.dealer_fee

    total_premium = new_transaction.total_premium
    transferred_premium = @policy.transferred_premium
    total_due = total_premium - transferred_premium

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
    fill :transaction_type, 'New policy'
    if payment_method.blank?
      fill :payment_method, 'N/A'
    else
      fill :payment_method, payment_method
    end

    fill :agent_comments, @policy.printed_agent_comments

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

    fill :less_transferred_premium_label, TRANSFERRED_PREMIUM_LABEL
    fill :less_transferred_premium, number_with_precision(transferred_premium, precision: 2, delimiter: ',')

    total_due_label = TOTAL_DUE_LABEL
    if total_due < 0
      total_due_label = TOTAL_REFUND_DUE_LABEL
    end

    fill :total_due_label, total_due_label
    fill :total_due, number_with_precision(total_due.abs, precision: 2, delimiter: ',')

    amount_financed = 0
    if @policy.billing_type === DIRECT_BILL
      amount_financed = total_due
    end

    fill :amount_financed_label, AMOUNT_FINANCED_LABEL
    fill :amount_financed, number_with_precision(amount_financed, precision: 2, delimiter: ',')

    amount_owed = total_due - amount_financed

    amount_owed_label = AMOUNT_OWED_LABEL
    if amount_owed < 0
      amount_owed_label = REFUND_OWED_LABEL
    end

    fill :amount_owed_label, amount_owed_label
    fill :amount_owed, number_with_precision(amount_owed.abs, precision: 2, delimiter: ',')

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