require 'pdf_forms'

class PrintReleaseOfInterest < FillablePdfForm

  include StringFunctions

  def initialize(policy)
    @policy = policy
    super()
  end

  protected

  def fill_out

    # GET ALL RELATED MODELS FROM @policy
    customer = @policy.customer
    cancelled_transaction = @policy.transactions.find_by(transaction_type: CANCELLED)

    # FIELD VARIABLES
    co_insured_full_name = "#{@policy.co_insured_first_name} #{@policy.co_insured_last_name}"

    #FILL
    fill :name, customer.name
    fill :co_insured_name, co_insured_full_name unless co_insured_full_name.blank?
    fill :make, @policy.make
    fill :policy_id, @policy.id
    fill :model, @policy.model
    fill :vin, @policy.vin.upcase
    fill :phone, format_phone(customer.phone)
    fill :address_city_province_postal_code, "#{customer.address}, #{customer.city}, #{customer.province}, #{customer.postal_code}"
    fill :agent_comments, cancelled_transaction.agent_comments
    fill :effective_date, cancelled_transaction.effective_date.strftime("%m/%d/%Y")

  end

end