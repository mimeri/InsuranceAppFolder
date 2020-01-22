require 'pdf_forms'

class PrintModifiedCertificate < FillablePdfForm

  include GeneralMethods

  def initialize(fields)
    @fields = fields
    super()
  end

  protected

  def fill_out

    # FIELD VARIABLES
    full_name = "#{@fields["first_name"]} #{@fields["last_name"]}"
    co_insured_full_name = "#{@fields["co_insured_first_name"]} #{@fields["co_insured_last_name"]}"
    co_insured_full_name_present = co_insured_full_name.present?
    lessor_name = @fields["lessor_name"]
    address = @fields["address"]
    city_province_postal_code = "#{@fields["city"]}, #{@fields["province"]}, #{@fields["postal_code"]}"

    broker_id = @fields["broker_id"]
    broker_name = get_broker_name(broker_id)

    user_id = @fields["user_id"]
    dealer_category = @fields["dealer_category"]
    dealer = @fields["dealer"]

    vehicle = "#{@fields["model_year"]} #{@fields["make"]} #{@fields["model"]}"
    vin = @fields["vin"]
    reg_num = @fields["reg_num"]
    purchase_date = @fields["purchase_date"].strftime("%b %-d, %Y")
    vehicle_price = "$#{@fields["vehicle_price"]}"
    odometer = "#{@fields["odometer"]} km"
    driver_factor = "#{@fields["driver_factor"]}"
    use_rate_class = @fields["use_rate_class"][0,3]

    coverage_type = @fields["coverage_type"]
    effective_date = @fields["effective_date"].to_date.strftime("%b %-d, %Y")
    policy_term = @fields["policy_term"]
    expiry_date =  @fields["expiry_date"].to_date.strftime("%b %-d, %Y")
    oem_body_parts = @fields["oem_body_parts"]

    payment_method = @fields["payment_method"]
    agent_comments = @fields["printed_agent_comments"]

    premium = @fields["coverage_premium"] + @fields["oem_body_parts_premium"]
    admin_fee = @fields["admin_fee"] + @fields["finance_admin_fee"]
    dealer_fee = @fields["dealer_fee"]
    total_premium = @fields["total_premium"]
    transferred_premium = @fields["transferred_premium"]
    total_due = total_premium - transferred_premium

    billing_type = @fields["billing_type"]

    # ================================================================================================================ #

    ## TOP
    fill :policy_id, @fields["policy_id"]

    # ---------------------------------------------------------------------------------------------------------------- #

    ## APPLICANT - INSURED
    fill :full_name, full_name

    if co_insured_full_name_present
      fill :co_insured_full_name, co_insured_full_name
      fill :co_insured_full_name_label, "Co-Insured's Name"
    end

    if lessor_name.present?
      fill :lessor_name_label, "Lease Company Name"
      fill :lessor_name, lessor_name
    end
    fill :address, address
    fill :city_province_postal_code, city_province_postal_code

    # -----------------------------------------------------------------------------------------------------------------#

    ## BROKER
    fill :broker_name, broker_name
    fill :broker_phone, format_phone(get_broker_phone(broker_id))
    fill :selling_agent, get_user_name(user_id) unless user_id.blank?

    if [OUT_OF_PROVINCE,PRIVATE_SALE].include?(dealer_category)
      fill :dealer, "N/A"
    else
      fill :dealer, dealer
    end

    # -----------------------------------------------------------------------------------------------------------------#

    ## DESCRIBED VEHICLE
    fill :vehicle, vehicle
    fill :vin, vin.upcase
    fill :reg_num, reg_num.to_s
    fill :purchase_date, purchase_date
    fill :vehicle_price, vehicle_price
    fill :odometer, odometer
    fill :driver_factor, '%.3f' % driver_factor
    fill :use_rate_class, use_rate_class

    # -----------------------------------------------------------------------------------------------------------------#

    ## COVERAGE TYPE AND TERM
    fill :coverage_type, coverage_type
    fill :effective_date, effective_date
    fill :policy_term, policy_term
    fill :expiry_date, expiry_date


    if oem_body_parts === YES_2_YEARS || oem_body_parts === YES_3_YEARS
      fill :oem_body_parts, "Yes - until "+ (effective_date.to_date + (oem_body_parts.partition(' - ').last[0].to_i).years).strftime("%b %-d, %Y")
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

    fill :agent_comments, agent_comments

    # -----------------------------------------------------------------------------------------------------------------#

    ## PREMIUMS AND FEES

    coverage_type_premium_label = "Vehicle "+@fields["coverage_type"]+" Insurance Premium: #{DOLLAR_LABEL}"
    fill :coverage_type_premium_label, coverage_type_premium_label
    fill :premium, ('%.2f' % premium)

    if oem_body_parts === (YES_3_YEARS or YES_2_YEARS)
      fill :oem_body_parts_premium_label, OEM_BODY_PARTS_INCLUDED_LABEL
      fill :oem_body_parts_included, "Included"
    end

    fill :admin_fee_label, POLICY_FEE_LABEL
    fill :admin_fee, ('%.2f' % admin_fee)

    if dealer_fee != 0
      fill :dealer_fee_label, DEALER_FEE_LABEL
      fill :dealer_fee, dealer_fee
    end

    fill :total_premium_label, TOTAL_PREMIUM_LABEL
    fill :total_premium, ('%.2f' % total_premium)

    fill :less_transferred_premium_label, TRANSFERRED_PREMIUM_LABEL
    fill :less_transferred_premium, ('%.2f' % transferred_premium)

    total_due_label = TOTAL_DUE_LABEL
    if total_due < 0
      total_due_label = TOTAL_REFUND_DUE_LABEL
    end

    fill :total_due_label, total_due_label
    fill :total_due, ('%.2f' % total_due.abs)

    amount_financed = 0
    if billing_type === DIRECT_BILL
      amount_financed = total_due
    end

    fill :amount_financed_label, AMOUNT_FINANCED_LABEL
    fill :amount_financed, ('%.2f' % amount_financed)

    amount_owed = total_due - amount_financed

    amount_owed_label = AMOUNT_OWED_LABEL
    if amount_owed < 0
      amount_owed_label = REFUND_OWED_LABEL
    end

    fill :amount_owed_label, amount_owed_label
    fill :amount_owed, ('%.2f' % amount_owed.abs)

    # -----------------------------------------------------------------------------------------------------------------#

    ## SIGNATURES

    fill :insured_signature_label, "Applicant's Signature"

    signature = 'X'

    fill :insured_signature, signature
    if co_insured_full_name_present
      fill :co_insured_signature_label, "Co-Applicant's Signature"
      fill :co_insured_signature, signature
    end

    certificate_type_printed = "BROKER'S COPY"

    fill :certificate_type, certificate_type_printed

  end

end