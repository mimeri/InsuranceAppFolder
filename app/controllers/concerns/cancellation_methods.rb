module CancellationMethods

  extend ActiveSupport::Concern
  include GeneralMethods
  include StringTemplates

  def get_refunds(id,cancellation_date,is_cancellation = true)
    transaction = Transaction.find(id)
    effective_date = transaction.effective_date
    expiry_date = transaction.expiry_date
    active_days = (cancellation_date.to_date - effective_date).to_i
    total_days = (expiry_date - effective_date).to_i
    refund_fraction = (total_days - active_days).to_f / total_days.to_f

    coverage_premium_refund = transaction.coverage_premium
    oem_body_parts_premium_refund = transaction.oem_body_parts_premium
    dealer_fee_refund = transaction.dealer_fee
    admin_fee_refund = transaction.admin_fee
    finance_admin_fee_refund = transaction.finance_admin_fee

    if (active_days > CANCELLATION_GRACE_PERIOD) and is_cancellation
      coverage_premium_refund *= refund_fraction
      oem_body_parts_premium_refund *= refund_fraction
      dealer_fee_refund *= refund_fraction
      admin_fee_refund = 0
      finance_admin_fee_refund = 0
    end

    total_refund = coverage_premium_refund + oem_body_parts_premium_refund + dealer_fee_refund + admin_fee_refund + finance_admin_fee_refund
    return coverage_premium_refund.round(2), oem_body_parts_premium_refund.round(2), dealer_fee_refund.round(2), admin_fee_refund.round(2), finance_admin_fee_refund.round(2), total_refund.round(2)
  end

  def get_unpaid_balance(policy,amount_refunded)
    if policy["billing_type"] === DIRECT_BILL
      xml_string = get_account_xml(policy["quote_number"])
      hash = snap_api_call(GET_ACCOUNT_URL,xml_string)
      if get_account_is_successful(hash)
        hash["Response"]["Data"]["Account"]["ZeroDayPayoffBalance"].gsub(/[^\d^\.]/, '').to_f
      else
        amount_refunded
      end
    else
      if policy["unpaid_balance"].present?
        policy["unpaid_balance"]
      else
        0
      end
    end
  end

end