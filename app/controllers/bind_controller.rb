require 'rest-client'

class BindController < ApplicationController

  include RateCalculation
  include CancellationMethods
  include StringTemplates

  before_action :check_employment, only: :new

  def new
    @policy = PolicyQuery.new.new_policy(@new_application_params)
    @transaction = @policy.transactions.new(new_transaction(@new_application_params).attributes)
  end

  def create
    new_application_params = Newapplication.find(bind_form_attributes["id"])

    ActiveRecord::Base.transaction do
      customer = new_customer(new_application_params)
      customer.save!
      policy = customer.policies.new(PolicyQuery.new.new_policy(new_application_params).attributes.merge(bind_form_attributes.except(:id)))
      policy.save!
      transaction = policy.transactions.new(new_transaction(new_application_params).attributes)
      transaction.save!
      if new_application_params["application_type"] === "transfer"
        cancelled_transaction = cancel_transferred_policy(policy.id, new_application_params["transferred_id"])
        cancelled_transaction.save!
      end
      Newapplication.find(bind_form_attributes["id"]).destroy!
      if policy.billing_type === DIRECT_BILL
        xml_string = quote_import_xml(customer,policy,transaction)
        hash = snap_api_call(QUOTE_IMPORT_URL,xml_string)
        if quote_import_is_successful(hash) === false
          raise StandardError.new hash["QuoteResponse"]["Errors"]["string"] || "Error: SNAP API call failed."
        end
        policy_pfa = policy.build_policy_pfa(pfa: hash["QuoteResponse"]["PFA"])
        policy_pfa.save!
        payment_details_url = Hash.from_xml(hash["QuoteResponse"]["QuoteInformation"]["OtherInfo"])["PaymentDetailsURL"]
        policy.update!(payment_details_url: payment_details_url)
        policy.update!(quote_number: hash["QuoteResponse"]["QuoteInformation"]["QuoteNumber"] )
        redirect_to payment_details_url
      else
        redirect_to policy_detail_path(id: policy.id)
      end
    end
  rescue ActiveRecord::RecordInvalid, StandardError => exception
    flash[:danger] = exception.message
    redirect_to bind_path(id: bind_form_attributes["id"])
  end

  def cancel_transferred_policy(policy_id, transferred_id)
    transferred_policy = Policy.find(transferred_id)
    transferred_policy.update!(status: TRANSFERRED)
    cancelled_transaction = new_cancellation_transaction(transferred_policy)
    cancelled_transaction.transaction_reason = CANCELLED_BY_CUSTOMER
    cancelled_transaction.agent_comments = "Automatic Cancellation due to premium balance transfer to Policy ID: #{policy_id}"
    cancelled_transaction
  end

  private

    def bind_form_attributes
      params.require(:bind_form).permit(:id, :payment_method, :printed_agent_comments)
    end

    def new_customer(params)
      if params["application_type"] === "new"
        CustomerQuery.new.new_customer(params)
      else
        Customer.find(params["customer_id"])
      end
    end

    def new_transaction(params)
      transaction = Transaction.new(effective_date: Date.current,
                                    expiry_date: (Date.current + (((params["policy_term"])[0]).to_i).years).to_date,
                                    user_id: current_user.id,
                                    agent_comments: params["agent_comments"],
                                    coverage_premium: calculate_premium( params["coverage_type"],
                                                                         params["model_year"],
                                                                         params["policy_term"],
                                                                         params["vehicle_price"],
                                                                         params["dealer_category"] ),
                                    oem_body_parts_premium: calculate_oem_premium( params["oem_body_parts"],
                                                                                      params["vehicle_price"] ),
                                    dealer_fee: get_dealer_fees(params["dealer_category"]),
                                    admin_fee: get_admin_fees(params["dealer_category"]),
                                    finance_admin_fee: get_finance_admin_fees(params["billing_type"]))
      transaction.total_premium = transaction.coverage_premium + transaction.oem_body_parts_premium + transaction.dealer_fee + transaction.admin_fee + transaction.finance_admin_fee
      transaction
    end

    def new_cancellation_transaction(transferred_policy)
      transferred_transaction = transferred_policy.transactions.find_by(transaction_type: "new")
      coverage_premium_val, oem_body_parts_premium_val, dealer_fee_val, admin_fee_val, finance_admin_fee_val, total_refund = get_refunds(transferred_transaction.id, Date.current)
      transferred_policy.update!(unpaid_balance: get_unpaid_balance(transferred_policy, total_refund))
      Transaction.new(effective_date: Date.current,
                      policy_id: transferred_policy.id,
                      expiry_date: transferred_transaction.expiry_date,
                      transaction_type: CANCELLED,
                      user_id: current_user.id,
                      coverage_premium: coverage_premium_val,
                      oem_body_parts_premium: oem_body_parts_premium_val,
                      dealer_fee: dealer_fee_val,
                      admin_fee: admin_fee_val,
                      finance_admin_fee: finance_admin_fee_val,
                      total_premium: total_refund)
    end

    def check_employment
      @new_application_params = Newapplication.find_by(id: params[:id])
      if @new_application_params.blank?
        redirect_to root_path
      else
        access_denied_broker(@new_application_params.broker_id)
      end
    end

end
