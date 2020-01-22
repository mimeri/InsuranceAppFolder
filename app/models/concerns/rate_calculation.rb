module RateCalculation

  extend ActiveSupport::Concern

  def get_policy_term_category(policy_term)
    case policy_term
    when '5 years'
      'fiveyearvalue'
    when '4 years'
      'fouryearvalue'
    when '3 years'
      'threeyearvalue'
    when '2 years'
      'twoyearvalue'
    else
      raise "Invalid policy term. #{REPORT}"
    end
  end

  def get_vehicle_price_category(vehicle_price)
    if vehicle_price.to_f < VEHICLE_PRICE_LOWEST_CATEGORY
      VEHICLE_PRICE_LOWEST_CATEGORY
    else
      VEHICLE_PRICE_INCREMENTS  * ((vehicle_price.to_f)/VEHICLE_PRICE_INCREMENTS.to_f).ceil
    end
  end

  def get_model_year_table(coverage_type,model_year)
    if coverage_type == LIMITED_DEPRECIATION
      'Limitedlookup'
    elsif coverage_type == FULL_REPLACEMENT
      year_diff = Date.current.year - model_year.to_i
      if year_diff <= 0
        'Yearonelookup'
      elsif year_diff === 1
        'Yeartwolookup'
      elsif year_diff > 1
        raise "Invalid model year. #{REPORT}"
      end
    end
  end

  def calculate_premium(coverage_type,model_year,policy_term,vehicle_price,dealer_category)
    table_name = get_model_year_table(coverage_type,model_year)
    policy_term_category = get_policy_term_category(policy_term)
    vehicle_price_category = get_vehicle_price_category(vehicle_price)
    premium = table_name.constantize.where(vehicleprice: vehicle_price_category).first.instance_eval(policy_term_category)
    if [OUT_OF_PROVINCE,PRIVATE_SALE].include?(dealer_category)
      premium += DEALER_FEE
    end
    premium
  end

  def calculate_oem_premium(oem_body_parts,vehicle_price)
    if oem_body_parts === NOT_ELIGIBLE
      0
    elsif oem_body_parts === YES_3_YEARS || oem_body_parts === YES_2_YEARS
      vehicle_price_category = get_vehicle_price_category(vehicle_price)
      Oemlookup.where(vehicleprice: vehicle_price_category).first.instance_eval("oem").round
    end
  end

  def get_dealer_fees(dealer_category)
    if dealer_category === NOT_TESLA
      DEALER_FEE
    else
      NO_DEALER_FEE
    end
  end

  def get_admin_fees(dealer_category)
    if dealer_category === TESLA
      TESLA_ADMIN_FEE
    else
      ADMIN_FEE
    end
  end

  def get_finance_admin_fees(billing_type)
    if billing_type === BROKER_BILL
      0
    elsif billing_type === DIRECT_BILL
      FINANCE_ADMIN_FEE
    end
  end

  def convert_financing_term_to_int(financing_term)
    months = nil
    case financing_term
    when '48 months'
      months = 48
    when '36 months'
      months = 36
    when '24 months'
      months = 24
    when '12 months'
      months = 12
    else
      "Error"
    end
    months
  end

  def calculate_amount_financed(billing_type,total)
    if billing_type === BROKER_BILL
      0
    elsif billing_type === DIRECT_BILL
      total
    end
  end

end

