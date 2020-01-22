class CustomerQuery

  attr_reader :relation

  def initialize(relation = Customer)
    @relation = relation
  end

  def new_customer(params)
    relation.new(insured_type: params["insured_type"],
                 first_name: params["first_name"],
                 last_name: params["last_name"],
                 name: params["name"],
                 address: params["address"],
                 city: params["city"],
                 province: params["province"],
                 postal_code: params["postal_code"],
                 phone: params["phone"],
                 email: params["email"])
  end

end