class PolicyDetailController < ApplicationController

  include CancellationMethods

  before_action :check_employment, only: :show

  def show
    @new_transaction = @policy.transactions.find_by(transaction_type: "new")
    @cancelled_transaction = @policy.transactions.find_by(transaction_type: CANCELLED)
    @original_transferred = Policy.find_by(id: @policy.transferred_id) unless @policy.transferred_id.blank?
    @all_policies = Policy.where(customer_id: @policy.customer_id)
    @policy.update_snap_status
  end

  def new_policy_same_customer
    @customer = Customer.find(params[:id])
    @newapplication = create_new_application(@customer)
    @newapplication.save!(validate: false)
    redirect_to edit_newapplication_step1_path(id: @newapplication.id)
  end

  def edit_customer
    ActiveRecord::Base.transaction do
      @policy = Policy.find(customer_params["id"])
      full_name = customer_params["first_name"] + " " + customer_params["last_name"]
      @policy.customer.update! customer_params.merge(name: full_name).except(:id)
      flash_success
      redirect_to policy_detail_path(id: @policy.id)
    end
  rescue ActiveRecord::RecordInvalid => exception
    flash[:danger] = exception.message
    redirect_to policy_detail_path(id: @policy.id)
  end

  def edit_policy
    ActiveRecord::Base.transaction do
      @policy = Policy.find(policy_params["id"])
      if invalid_policy_status(@policy)
        redirect_to policy_detail_path(id: @policy.id) and return
      end
      @policy.update! policy_params.except(:id)
      flash_success
      redirect_to policy_detail_path(id: @policy.id)
    end
  rescue ActiveRecord::RecordInvalid => exception
    flash[:danger] = exception.message
    redirect_to policy_detail_path(id: @policy.id)
  end

  def edit_transaction
    ActiveRecord::Base.transaction do
      @transaction = Transaction.find(transaction_params["id"])
      @transaction.update! transaction_params.except(:id)
      flash_success
      redirect_to policy_detail_path(id: @transaction.policy_id)
    end
  rescue ActiveRecord::RecordInvalid => exception
    flash[:danger] = exception.message
    redirect_to policy_detail_path(id: @transaction.policy_id)
  end

  def cancel_policy
    @policy = Policy.find(cancel_policy_params["id"])
    @new_transaction = @policy.transactions.find_by(transaction_type: "new")
    input_effective_date = cancel_policy_params["effective_date"]

    if invalid_effective_date(input_effective_date, @new_transaction.effective_date.to_date)
      redirect_to policy_detail_path(id: @policy.id) and return
    end

    if invalid_policy_status(@policy) or invalid_cancel_action(@policy)
      redirect_to policy_detail_path(id: @policy.id) and return
    end

    ActiveRecord::Base.transaction do
      total_refund = new_cancellation_transaction(@policy.id, @new_transaction, cancel_policy_params["agent_comments"], input_effective_date || Date.current)
      @policy.update!(status: CANCELLED)
      @policy.update!(unpaid_balance: get_unpaid_balance(@policy,total_refund))
      @cancelled_transaction.transaction_reason = cancel_policy_params["transaction_reason"]
      @cancelled_transaction.save!
      if @policy.billing_type === DIRECT_BILL
        begin
          SnapMailer.cancellation_email(@policy).deliver
        rescue Net::SMTPAuthenticationError, Net::SMTPServerBusy, Net::SMTPSyntaxError, Net::SMTPFatalError, Net::SMTPUnknownError => exception
          flash[:warning] = "Automatic cancellation email to SNAP failed to send. You will need to send this email manually. Reason for failure: #{exception.message}"
        else
          flash[:success] = "An automatic email has been sent to SNAP Financial requesting the cancellation of this policy."
        end
      end
      flash[:success] = "Policy successfully cancelled."
      redirect_to policy_detail_path(id: @policy.id)
    end

  rescue ActiveRecord::RecordInvalid => exception
    flash[:danger] = exception.message
    redirect_to policy_detail_path(id: @policy.id)
  end

  def void_policy
    @policy = Policy.find(void_policy_params["id"])
    @new_transaction = @policy.transactions.find_by(transaction_type: "new")

    if invalid_policy_status(@policy) or invalid_void_action(@policy)
      redirect_to policy_detail_path(id: @policy.id) and return
    end

    ActiveRecord::Base.transaction do
      total_refund = new_cancellation_transaction(@policy.id, @new_transaction,void_policy_params["agent_comments"],Date.current,false)
      @policy.update!(status: VOID)
      if @policy.billing_type === DIRECT_BILL
        @policy.update!(unpaid_balance: total_refund)
      end
      @cancelled_transaction.transaction_reason = CANCELLED_BY_CUSTOMER
      @cancelled_transaction.save!
      if @policy.transferred_id.present?
        transferred_policy = Policy.find(@policy.transferred_id)
        transferred_policy.update!(status: BOUND)
        transferred_policy.transactions.where(transaction_type: CANCELLED).destroy_all
        flash[:success] = "Policy successfully voided. The policy that was transferred to this voided policy is now active.
                           Click #{view_context.link_to "Here", policy_detail_path(id: transferred_policy.id)} to view the policy detail page of the transferred policy."
      else
        flash[:success] = "Policy successfully voided."
      end
      redirect_to policy_detail_path(id: @policy.id)
    end
  rescue ActiveRecord::RecordInvalid => exception
    flash[:danger] = exception.message
    redirect_to policy_detail_path(id: @policy.id)
  end

  def transfer_policy
    @policy = Policy.find(transfer_policy_params["id"])
    @new_transaction = @policy.transactions.find_by(transaction_type: "new")

    if invalid_policy_status(@policy) or invalid_transfer_action(@policy)
      redirect_to policy_detail_path(id: @policy.id) and return
    end

    ActiveRecord::Base.transaction do
      transferred_premium = transfer_policy_params["transferred_premium"]
      @newapplication = create_new_application(@policy.customer)
      @newapplication.transferred_premium = transferred_premium
      @newapplication.application_type = "transfer"
      @newapplication.transferred_id = @policy.id
      @newapplication.broker_id = @policy.broker_id
      @newapplication.save!(validate: false)
      redirect_to edit_newapplication_step1_path(id: @newapplication.id)
    end
  end

  def cancel_quote
    effective_date = get_effective_date(params[:effective_date])
    @new_transaction = Transaction.find(params[:id])
    @policy = Policy.find(@new_transaction.policy_id)
    @amount_refunded = get_refunds(@new_transaction.id,effective_date).last
    @unpaid_balance = get_unpaid_balance(@policy,@amount_refunded)
  end

  private

    def flash_success
      flash[:success] = "Changes saved successfully"
    end

    def customer_params
      params.require(:customer_info).permit(:id, :insured_type, :first_name, :last_name, :address, :city, :province, :postal_code, :phone, :email)
    end

    def policy_params
      params.require(:policy_info).permit(:id, :driver_factor, :lessor_name, :co_insured_first_name, :co_insured_last_name, :payment_method, :unpaid_balance)
    end

    def transaction_params
      params.require(:transaction_info).permit(:id, :agent_comments)
    end

    def cancel_policy_params
      params.require(:cancel_policy).permit(:id, :transaction_reason, :agent_comments, :effective_date)
    end

    def void_policy_params
      params.require(:void_policy).permit(:id, :agent_comments)
    end

    def transfer_policy_params
      params.require(:transfer_policy).permit(:id, :transferred_premium)
    end

    def create_new_application(customer)
      NewapplicationForm.new(insured_type: customer["insured_type"],
                             first_name: customer["first_name"],
                             last_name: customer["last_name"],
                             address: customer["address"],
                             city: customer["city"],
                             province: customer["province"],
                             postal_code: customer["postal_code"],
                             phone: customer["phone"],
                             email: customer["email"],
                             application_type: "another",
                             customer_id: customer["id"])
    end

    def new_cancellation_transaction(policy_id, new_transaction, agent_comments, input_effective_date, is_cancellation = true)
      coverage_premium_val, oem_body_parts_premium_val, dealer_fee_val, admin_fee_val, finance_admin_fee_val, total_refund_val = get_refunds(new_transaction.id, input_effective_date, is_cancellation)
      @cancelled_transaction = Transaction.new(effective_date: input_effective_date,
                                               policy_id: policy_id,
                                               expiry_date: new_transaction.expiry_date,
                                               transaction_type: CANCELLED,
                                               agent_comments: agent_comments,
                                               user_id: current_user.id,
                                               coverage_premium: coverage_premium_val,
                                               oem_body_parts_premium: oem_body_parts_premium_val,
                                               dealer_fee: dealer_fee_val,
                                               admin_fee: admin_fee_val,
                                               finance_admin_fee: finance_admin_fee_val,
                                               total_premium: total_refund_val)
      total_refund_val
    end

    def invalid_policy_status(policy)
      if policy.is_bound === false
        flash[:danger] = "Action failed. Policy is not active. #{REPORT}"
        true
      elsif (policy.transactions.find_by(transaction_type: "new").expiry_date - Date.current).to_i <= CANT_CANCEL_B4_EXPIRATION
        flash[:danger] = "Action failed. The difference between the expiry date of this policy and the current date is less than or equal to #{CANT_CANCEL_B4_EXPIRATION} days. #{REPORT}"
        true
      else
        false
      end
    end

    def check_employment
      @policy = Policy.find(params[:id])
      access_denied_broker(@policy.broker_id)
    end

    def invalid_effective_date(input_effective_date,curr_effective_date)
      if input_effective_date.present?
        if input_effective_date.to_date > Date.current or input_effective_date.to_date < curr_effective_date
          flash[:danger] = "Action failed. Effective date of action must be before current date and after effective date of policy"
          return true
        end
        if get_permission_level(current_user.id,@policy.broker_id) > UNDERWRITER_LEVEL
          flash[:danger] = "Action failed. Only underwriters and administrators can specify effective date of this action. #{REPORT}"
          return true
        end
      end
      false
    end

    def get_effective_date(effective_date_input)
      if effective_date_input.present?
        effective_date_input.to_date
      else
        Date.current
      end
    end

    def invalid_void_action(policy)
      policy.update_snap_status
      if policy.can_void(@new_transaction.effective_date)
        false
      else
        flash[:danger] = "Void Action failed. #{REPORT}"
        true
      end
    end

    def invalid_cancel_action(policy)
      if policy.can_cancel
        false
      else
        flash[:danger] = "Cancel Action failed. #{REPORT}"
        true
      end
    end

    def invalid_transfer_action(policy)
      if policy.can_transfer
        false
      else
        flash[:danger] = "Transfer Action failed. #{REPORT}"
        true
      end
    end

end