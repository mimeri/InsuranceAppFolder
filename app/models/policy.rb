class Policy < ApplicationRecord

  include CustomValidations
  include StringTemplates
  attr_accessor :user_id

  belongs_to :customer
  belongs_to :broker
  has_many :transactions
  has_one :policy_pfa

  before_save :normalize_blank_values

  has_paper_trail on: [:update], only: [:driver_factor, :lessor_name, :co_insured_first_name, :co_insured_last_name, :payment_method]

  # step 1
  # validate :broker_id_validations, on: :create
  validate :model_year_validations, on: :create
  validate :purchase_date_validations, on: :create
  validate :dealer_category_validations, on: :create
  validate :dealer_validations, on: :create
  validate :use_rate_class_validations, on: :create
  validate :gvw_validations, on: :create
  validate :vehicle_price_validations, on: :create
  validate :odometer_validations, on: :create

  #step 2
  validate :coverage_type_validations, on: :create
  validate :policy_term_validations, on: :create
  validate :oem_validations, on: :create
  validate :billing_type_validations, on: :create
  validate :financing_term_validations, on: :create

  #step 3
  validate :driver_factor_validations
  validate :make_validations, on: :create
  validate :model_validations, on: :create
  validate :vin_validations, on: :create
  validate :reg_num_validations, on: :create
  validate :co_insured_validations

  #bind step
  validate :payment_method_validations
  validate :customer_id_validations, on: :create
  validate :vehicle_validations, on: :create
  validate :transferred_validations, on: :create
  validate :policy_comments_validations, on: :create

  # edit policy
  validate :unpaid_balance_validations, on: :update

  # GETTER functions

  def is_bound
    status === BOUND
  end

  def is_expired
    status === EXPIRED
  end

  def is_cancelled
    status === CANCELLED
  end

  def is_void
    status === VOID
  end

  def is_transferred
    status === TRANSFERRED
  end

  def snap_status_is_active
    snap_status === SNAP_ACTIVE
  end

  def snap_status_is_not_active
    snap_status == SNAP_NOT_ACTIVE
  end

  def snap_status_is_cancelled
    snap_status === SNAP_CANCELLED
  end

  def is_not_accepted_by_snap
    (billing_type === DIRECT_BILL) and is_bound and snap_status_is_not_active
  end

  def is_not_cancelled_by_snap
    (billing_type === DIRECT_BILL) and is_cancelled and snap_status_is_active
  end

  def can_void(effective_date)
    if billing_type === BROKER_BILL
      ((Date.current - effective_date).to_i <= VOID_GRACE_PERIOD) and (unpaid_balance === 0)
    elsif billing_type === DIRECT_BILL
      (snap_status_is_not_active) and (unpaid_balance === 0)
    end
  end

  def can_cancel
    if billing_type === DIRECT_BILL
      (quote_number.present?) and (!snap_status_is_not_active) and (snap_account_number.present?)
    else
      true
    end
  end

  def can_transfer
    (billing_type === BROKER_BILL) and (unpaid_balance === 0)
  end

  ## SETTER functions

  def update_snap_status
    if billing_type === DIRECT_BILL
      if (quote_number.present?) and ([SNAP_NOT_ACTIVE,SNAP_ACTIVE].include?(snap_status))
        xml_string = get_account_xml(quote_number)
        hash = snap_api_call(GET_ACCOUNT_URL,xml_string)
        if get_account_is_successful(hash)
          snap_account_status = get_snap_account_status(hash)
          if snap_account_number.blank?
            self.update!(snap_account_number: get_snap_account_number(hash))
          end
          # UPDATE FROM 'Not active' to 'Active' if policy is bound and SNAP has account status as Current
          if is_bound and snap_status_is_not_active and (snap_account_status === "Current")
            self.update!(snap_status: SNAP_ACTIVE)
          # UPDATE FROM 'Active' to 'Cancelled' if policy is cancelled and SNAP has account status as Cancelled
          elsif is_cancelled and snap_status_is_active and (snap_account_status === "Cancelled")
            self.update!(snap_status: SNAP_CANCELLED)
          end
        end
      end
    end
  end

end
