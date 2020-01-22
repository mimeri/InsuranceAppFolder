class PolicyQuery

  attr_reader :relation

  include StringFunctions

  def initialize(relation = Policy)
    @relation = relation
  end

  def find_by_name(name)
    customer = Customer.find_by(name: name)
    if customer.present?
      relation.find_by(customer_id: customer.id)
    end
  end

  def new_policy(params)
    relation.new(model_year: params["model_year"],
                 purchase_date: params["purchase_date"],
                 dealer: upcase_field(params["dealer"]),
                 vehicle_price: params["vehicle_price"],
                 odometer: params["odometer"],
                 use_rate_class: params["use_rate_class"],
                 coverage_type: params["coverage_type"],
                 policy_term: params["policy_term"],
                 oem_body_parts: params["oem_body_parts"],
                 billing_type: params["billing_type"],
                 financing_term: params["financing_term"],
                 make: params["make"],
                 model: params["model"],
                 vin: params["vin"].upcase,
                 reg_num: params["reg_num"],
                 lessor_name: params["lessor_name"],
                 co_insured_last_name: params["co_insured_last_name"],
                 co_insured_first_name: params["co_insured_first_name"],
                 payment_method: params["payment_method"],
                 gvw: params["gvw"],
                 vehicle: params["vehicle"],
                 transferred_premium: params["transferred_premium"],
                 transferred_id: params["transferred_id"],
                 driver_factor: params["driver_factor"],
                 printed_agent_comments: params["agent_comments"],
                 dealer_category: params["dealer_category"],
                 broker_id: params["broker_id"] )
  end

end