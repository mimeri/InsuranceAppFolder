require 'uri'

module CustomValidations
  extend ActiveSupport::Concern
  include RateCalculation
  include GeneralMethods

  def first_step_validations
    user_id_validations
    broker_id_validations
    driver_factor_validations
    model_year_validations
    purchase_date_validations
    dealer_category_validations
    dealer_validations
    vehicle_price_validations
    odometer_validations
    use_rate_class_validations
    gvw_validations
  end

  def second_step_validations
    coverage_type_validations
    policy_term_validations
    oem_validations
    billing_type_validations
    financing_term_validations
    monthly_payment_validations
  end

  def third_step_validations
    insured_type_validations
    first_name_validations
    last_name_validations
    full_name_validations
    address_validations
    city_validations
    province_validations
    postal_code_validations
    combined_validations
    phone_validations
    email_validations
    make_validations
    model_validations
    make_model_validations
    vin_validations
    reg_num_validations
    lessor_name_validations
    co_insured_validations
  end

  def fourth_step_validations
  end



  def user_id_validations
    if user_id.present?
      if (User.all.ids).include?(user_id) === false
        errors.add(:user_id, IS_INVALID_REPORT)
      end
    else
      errors.add(:user_id, CANT_BE_BLANK_REPORT)
    end
  end



  def broker_id_validations
    if broker_id.present?
      broker_id_list = Employment.where(user_id: user_id).pluck(:broker_id)
      if broker_id_list.include?(broker_id) === false
        errors.add(:broker_id, IS_INVALID_REPORT)
      end
      if transferred_id.present?
        policy = Policy.find(transferred_id)
        if policy.broker_id != broker_id
          errors.add(:broker_id, IS_INVALID_REPORT)
        end
      end
    else
      errors.add(:broker_id, CANT_BE_BLANK_REPORT)
    end
  end



  def effective_date_validations
    if effective_date.blank?
      errors.add(:effective_date, CANT_BE_BLANK)
    end
  end



  def model_year_validations
    if model_year.blank?
      errors.add(:model_year, CANT_BE_BLANK_REPORT)
    else
      model_year_val = model_year.to_i
      min_model_year = Date.current.year - 10
      max_model_year = Date.current.year + 1
      if model_year_val.between?(min_model_year,max_model_year) === false
        errors.add(:model_year, "must be between #{min_model_year} and #{max_model_year}. #{REPORT}")
      end
    end
  end



  def purchase_date_validations
    if purchase_date.present?
      if purchase_date > Date.current
        errors.add(:purchase_date, "can't be a future date.")
      end
      if (model_year.present?) and (purchase_date.year < (model_year - MIN_PURCHASE_YEAR_DIFF))
        errors.add(:purchase_date, "can't be #{MIN_PURCHASE_YEAR_DIFF} years before model year. #{REPORT}")
      end
    else
      errors.add(:purchase_date, CANT_BE_BLANK_REPORT)
    end
  end



  def dealer_category_validations
    if dealer_category.blank?
      errors.add(:dealer_category, CANT_BE_BLANK_REPORT)
    else
      @dealer_category_array = [NOT_TESLA,TESLA,PRIVATE_SALE,OUT_OF_PROVINCE]
      if @dealer_category_array.include?(dealer_category) === false
        errors.add(:dealer_category, IS_INVALID_REPORT)
      end
    end
  end



  def dealer_validations
    if dealer_category.present?
      if dealer.blank?
        if dealer_category === NOT_TESLA or dealer_category === TESLA
          errors.add(:dealer, CANT_BE_BLANK)
        end
      else
        if dealer_category === PRIVATE_SALE or dealer_category === OUT_OF_PROVINCE
          errors.add(:dealer, SHOULD_NOT_BE_PRESENT_REPORT)
        end
      end
    end
  end



  def use_rate_class_validations
    if use_rate_class.present?
      @use_rate_class_array = ['001 - PLEASURE USE',
                               '002 - OVER 15 km TO WORK',
                               '003 - UNDER 15 km TO WORK',
                               '004 - P/T PUBLIC TRANSIT',
                               '007 - BUSINESS USE',
                               '011 - FARM USE',
                               '012 - ARTISAN USE',
                               '014 - FISHER USE']

      if @use_rate_class_array.include?(use_rate_class) === false
        errors.add(:use_rate_class, IS_INVALID_REPORT)
      end
    else
      errors.add(:use_rate_class, CANT_BE_BLANK)
    end
  end



  def vehicle_price_validations
    if vehicle_price.present?
      if vehicle_price.to_i < 0
        errors.add(:vehicle_price, "can't have a negative value")
      elsif vehicle_price.to_i > 150000
        errors.add(:vehicle_price, "can't be more than $150,000")
      end
    else
      errors.add(:vehicle_price, CANT_BE_BLANK)
    end
  end



  def gvw_validations
    @non_gvw_classes = ['',
                        '001 - PLEASURE USE',
                        '002 - OVER 15 km TO WORK',
                        '003 - UNDER 15 km TO WORK',
                        '004 - P/T PUBLIC TRANSIT',
                        '007 - BUSINESS USE']
    @gvw_classes = ['011 - FARM USE',
                    '012 - ARTISAN USE',
                    '014 - FISHER USE']
    if gvw.present?
      if @non_gvw_classes.include?(use_rate_class)
        errors.add(:gvw, "should not have a value. #{REPORT}")
      elsif @gvw_classes.include?(use_rate_class)

        if (gvw.is_a?(Integer) rescue ArgumentError) === ArgumentError
          errors.add(:gvw, "is not an integer. #{REPORT}")
        else
          if gvw <= 0 or gvw > 5000
            errors.add(:gvw, "should have a value between 1 and 5000kg.")
          end
        end
      end
    end
    if gvw.blank?
      if use_rate_class.present? and @gvw_classes.include?(use_rate_class)
        errors.add(:gvw, "should have a value between 1 and 5000kg.")
      end
    end
  end



  def odometer_validations
    if odometer.present?
      if odometer <= 0
        errors.add(:odometer, "can't be less than or equal to 0 km")
      end
    else
      errors.add(:odometer, CANT_BE_BLANK)
    end
  end



  def coverage_type_validations
    if coverage_type.blank?
      errors.add(:coverage_type, CANT_BE_BLANK_REPORT)
    else
      coverage_type_options = [FULL_REPLACEMENT,LIMITED_DEPRECIATION]
      if coverage_type_options.include?(coverage_type) === false
        errors.add(:coverage_type, "should either be '#{FULL_REPLACEMENT}' or '#{LIMITED_DEPRECIATION}'. #{REPORT}")
      else
        if (odometer.present?) and (odometer > MAX_ODOMETER) and (coverage_type === FULL_REPLACEMENT)
          errors.add(:coverage_type, "should not be '#{FULL_REPLACEMENT}'. #{REPORT}")
        end
        if (model_year < (Date.current.year - 1)) and (coverage_type === FULL_REPLACEMENT)
          errors.add(:coverage_type, "can't be '#{FULL_REPLACEMENT}' if model year of the vehicle is more than one year before the effective year of the policy. #{REPORT}")
        end
      end
    end
  end



  def policy_term_validations
    if policy_term.present?
      policy_term_options = ["5 years","4 years","3 years","2 years"]
      if policy_term_options.include?(policy_term) === false
        errors.add(:policy_term, IS_INVALID_REPORT)
      else
        model_year_val = model_year.to_i
        if model_year_val < Date.current.year-7
          if model_year_val === Date.current.year - 8
            if policy_term_options[0,1].include?(policy_term)
              errors.add(:policy_term, "is invalid according to the model year inputted. #{REPORT}")
            end
          elsif model_year_val === Date.current.year - 9
            if policy_term_options[0,2].include?(policy_term)
              errors.add(:policy_term, "is invalid according to the model year inputted. #{REPORT}")
            end
          elsif model_year_val < Date.current.year - 9
            if policy_term_options[0,3].include?(policy_term)
              errors.add(:policy_term, "is invalid according to the model year inputted. #{REPORT}")
            end
          end
        end
      end
    else
      errors.add(:policy_term, CANT_BE_BLANK_REPORT)
    end
  end



  def oem_validations
    if oem_body_parts.present?
      oem_body_parts_options = [YES_3_YEARS,YES_2_YEARS,NOT_ELIGIBLE]

      if oem_body_parts_options.include?(oem_body_parts) === false
        errors.add(:oem_body_parts, IS_INVALID_REPORT)
      elsif (coverage_type.present?) and (model_year.present?) and (policy_term.present?)
        model_year_val = model_year.to_i

        oem_is_not_eligible = (oem_body_parts === NOT_ELIGIBLE)
        oem_is_yes_3_years = (oem_body_parts === YES_3_YEARS)
        oem_is_yes_2_years = (oem_body_parts === YES_2_YEARS)

        valid_yes_3_years = ((coverage_type === FULL_REPLACEMENT) and (policy_term != "2 years") and (model_year_val >= (Date.current.year-1)))
        valid_yes_2_years = ((coverage_type === FULL_REPLACEMENT) and (policy_term === "2 years") and (model_year_val >= (Date.current.year-1)))
        valid_not_eligible = ((coverage_type === LIMITED_DEPRECIATION) or (model_year_val < (Date.current.year - 1)))

        valid_array = [valid_yes_3_years,valid_yes_2_years,valid_not_eligible]
        true_count = 0
        valid_array.each do |valid_bool|
          true_count += 1 if valid_bool
        end
        errors.add(:base, "Invalid oem_body_parts validation. #{REPORT}") if true_count != 1

        if (oem_is_not_eligible and !valid_not_eligible) or (oem_is_yes_3_years and !valid_yes_3_years) or (oem_is_yes_2_years and !valid_yes_2_years)
          errors.add(:oem_body_parts, "is invalid according to other inputs. #{REPORT}")
        end
      end
    else
      errors.add(:oem_body_parts, CANT_BE_BLANK_REPORT)
    end
  end



  # ## Old oem validations before Yes - x years change
  # def oem_validations_ayy
  #   if oem_body_parts.present?
  #     oem_body_parts_options = [YES_3_YEARS,YES_2_YEARS,NOT_ELIGIBLE]
  #
  #     if oem_body_parts_options.include?(oem_body_parts) === false
  #       errors.add(:oem_body_parts, IS_INVALID_REPORT)
  #     elsif (model_year.present?) and (policy_term.present?)
  #       model_year_val = model_year.to_i
  #
  #       oem_is_not_eligible = (oem_body_parts === NOT_ELIGIBLE)
  #       oem_is_yes_3_years = (oem_body_parts === YES_3_YEARS)
  #       oem_is_yes_2_years = (oem_body_parts === YES_2_YEARS)
  #
  #       valid_yes_3_years = ((coverage_type === FULL_REPLACEMENT) and (policy_term != "2 years") and (model_year_val >= Date.current.year))
  #       valid_yes_2_years = ((coverage_type === FULL_REPLACEMENT) and (policy_term === "2 years" or model_year_val === (Date.current.year - 1)))
  #       valid_not_eligible = ((coverage_type === LIMITED_DEPRECIATION) or (model_year_val < (Date.current.year - 1)))
  #
  #       valid_array = [valid_yes_3_years,valid_yes_2_years,valid_not_eligible]
  #       true_count = 0
  #       valid_array.each do |valid_bool|
  #         true_count += 1 if valid_bool
  #       end
  #       errors.add(:base, "Invalid oem_body_parts validation. #{REPORT}") if true_count != 1
  #
  #       if (oem_is_not_eligible and !valid_not_eligible) or (oem_is_yes_3_years and !valid_yes_3_years) or (oem_is_yes_2_years and !valid_yes_2_years)
  #         errors.add(:oem_body_parts, "is invalid according to other inputs. #{REPORT}")
  #       end
  #     end
  #   else
  #     errors.add(:oem_body_parts, CANT_BE_BLANK_REPORT)
  #   end
  # end



  def billing_type_validations
    if billing_type.present?

      billing_type_options = [BROKER_BILL,DIRECT_BILL]
      if billing_type_options.include?(billing_type) === false
        errors.add(:billing_type, IS_INVALID_REPORT)
      end
    else
      errors.add(:billing_type, CANT_BE_BLANK_REPORT)
    end
  end



  def financing_term_validations
    if financing_term.present?
      if billing_type.present?
        if billing_type === BROKER_BILL
          errors.add(:financing_term, "should not be present. #{REPORT}")
        elsif billing_type === DIRECT_BILL
          financing_term_options = ["48 months","36 months","24 months","12 months"]
          if financing_term_options.include?(financing_term) === false
            errors.add(:financing_term, IS_INVALID_REPORT)

          else
            has_error = false
            if policy_term === "5 years" and financing_term === "12 months"
              has_error = true
            elsif policy_term === "4 years" and (financing_term === "12 months" or financing_term === "48 months")
              has_error = true
            elsif policy_term === "3 years" and financing_term != "24 months"
              has_error = true
            elsif policy_term === "2 years" and financing_term != "12 months"
              has_error = true
            end

            if has_error === true
              errors.add(:financing_term, IS_INVALID_REPORT)
            end

          end
        end
      end
    else
      if billing_type === DIRECT_BILL
        errors.add(:financing_term, CANT_BE_BLANK_REPORT)
      end
    end
  end



  def monthly_payment_validations
    if billing_type.present?
      if billing_type === DIRECT_BILL
        if monthly_payment.blank?
          errors.add(:monthly_payment, CANT_BE_BLANK_REPORT)
        else
          if monthly_payment.is_a?(Float)
            if monthly_payment <= 0
              errors.add(:monthly_payment, IS_INVALID_REPORT)
            end
          else
            errors.add(:base, "SNAP Error: '"+monthly_payment+"'")
          end
        end
      elsif billing_type === BROKER_BILL
        if monthly_payment.present?
          errors.add(:monthly_payment, SHOULD_NOT_BE_PRESENT_REPORT)
        end
      end
    end
  end


  def expiry_date_validations
    if expiry_date.blank?
      errors.add(:expiry_date, CANT_BE_BLANK_REPORT)
    end
  end



  def insured_type_validations
    if insured_type.present?
      if ["Person","Company"].include?(insured_type) === false
        errors.add(:insured_type, IS_INVALID_REPORT)
      end
    else
      errors.add(:insured_type, CANT_BE_BLANK_REPORT)
    end
  end



  def first_name_validations
    if first_name.blank?
      errors.add(:first_name, CANT_BE_BLANK)
    else
      if first_name.include?('"')
        errors.add(:first_name, CANT_CONTAIN_DOUBLE_QUOTATIONS)
      end
    end
  end



  def last_name_validations
    if last_name.present?
      if insured_type.present? and insured_type === "Company"
        errors.add(:last_name, "should not be present. #{REPORT}")
      end
      if last_name.include?('"')
        errors.add(:last_name, CANT_CONTAIN_DOUBLE_QUOTATIONS)
      end
    else
      if insured_type.present? and insured_type === "Person"
        errors.add(:last_name, CANT_BE_BLANK)
      end
    end
  end



  def full_name_validations
    full_name = ""
    if first_name.present?
      full_name += first_name
    end
    if last_name.present?
      full_name += last_name
    end
    max_length = 52
    if full_name.present? and full_name.length > max_length
      errors.add(:base, "Full name exceeds #{max_length} characters and will overrun in the PDF sheet")
    end
  end



  def address_validations
    if address.present?
      max_length = 52
      if address.length > max_length
        errors.add(:address, "exceeds #{max_length} characters and will overrun in the PDF sheet")
      end
      if address.include?('"')
        errors.add(:address, CANT_CONTAIN_DOUBLE_QUOTATIONS)
      end
    else
      errors.add(:address, CANT_BE_BLANK)
    end
  end



  def city_validations
    if city.blank?
      errors.add(:city, CANT_BE_BLANK)
    else
      if city.include?('"')
        errors.add(:city, CANT_CONTAIN_DOUBLE_QUOTATIONS)
      end
    end
  end



  def province_validations
    if province.present?
      if province != "BC"
        errors.add(:province, "should be 'BC'")
      end
    else
      errors.add(:province, CANT_BE_BLANK)
    end
  end



  def postal_code_validations
    if postal_code.present?
      errors.add(:base, "Invalid Canadian postal code") unless postal_code =~ /^[ABCEGHJ-NPRSTVXY]\d[ABCEGHJ-NPRSTV-Z][ -]?\d[ABCEGHJ-NPRSTV-Z]\d$/i
    else
      errors.add(:postal_code, CANT_BE_BLANK)
    end
  end



  def combined_validations
    if city.present? and province.present? and postal_code.present?
      string = city + province + postal_code
      max_length = 49
      if string.length > max_length
        errors.add(:base, "City, province, postal code combined exceed #{max_length} characters and will overrun in the PDF sheet")
      end
    end
  end



  def phone_validations
    if phone.present?
      max_length = 10
      if phone !~ /^[0-9]+$/
        errors.add(:phone, "must contain numbers only")
      elsif phone.length != max_length
        errors.add(:phone, "must have #{max_length} digits")
      end
    else
      errors.add(:phone, CANT_BE_BLANK)
    end
  end



  def email_validations
    if email.present?
      if email.match(URI::MailTo::EMAIL_REGEXP).blank?
        errors.add(:email, "is invalid. Please check the syntax")
      end
    else
      errors.add(:email, CANT_BE_BLANK)
    end
  end



  def driver_factor_validations
    if driver_factor.blank?
      errors.add(:driver_factor, CANT_BE_BLANK)
    else
      if driver_factor > 1
        errors.add(:driver_factor, "can't be greater than 1.000.")
      end
    end
  end



  def make_validations
    if make.blank?
      errors.add(:make, CANT_BE_BLANK)
    else
      if (dealer_category.present?) and (dealer_category === TESLA)
        if make != TESLA
          errors.add(:make, "should be #{TESLA}. #{REPORT}")
        end
      end
    end
  end



  def model_validations
    if model.blank?
      errors.add(:model, CANT_BE_BLANK)
    end
  end



  def make_model_validations
    if make.present? and model.present?
      string = make + model
      max_length = 47
      if string.length > max_length
        errors.add(:base, "Make and model combined exceed #{max_length} characters and will overrun in the PDF sheet")
      end
    end
  end



  def vin_validations
    if vin.present?
      if vin !~ /^[a-hj-npr-zA-HJ-NPR-Z0-9]+$/ ## no I, O, or Q
        errors.add(:base, "VIN is invalid. VIN should be alphanumeric and not contain 'I', 'O', or 'Q'")
      elsif vin.length != 17
        errors.add(:vin, "must contain exactly 17 characters")
      end
    else
      errors.add(:vin, CANT_BE_BLANK)
    end
  end



  def reg_num_validations
    if reg_num.present?
      if reg_num !~ /^[0-9]{7,8}$/
        errors.add(:reg_num, "is invalid. Registration number must contain 7 to 8 digits")
      end
    else
      errors.add(:reg_num, CANT_BE_BLANK)
    end
  end



  def lessor_name_validations
    if lessor_name.present?
      max_length = 52
      if lessor_name.length > max_length
        errors.add(:lessor_name, "exceeds #{max_length} characters and will overrun in the PDF sheet")
      end
    end
  end



  def co_insured_validations
    max_length = 255

    if co_insured_first_name.present?
      if co_insured_first_name.length > max_length
        errors.add(:co_insured_first_name, "exceeds #{max_length} and is too long")
      end
    else
      if co_insured_last_name.present?
        errors.add(:co_insured_last_name, "can't be present if first name is blank")
      end
    end

    if co_insured_last_name.present?
      if co_insured_last_name.length > max_length
        errors.add(:co_insured_last_name, "exceeds #{max_length} and is too long")
      end
    end
  end



  def payment_method_validations
    if payment_method.present?
      @payment_method_list = PAYMENT_METHOD_ARRAY

      if billing_type === DIRECT_BILL
        errors.add(:payment_method, "should not be present. #{REPORT}")

      elsif @payment_method_list.include?(payment_method) === false
        errors.add(:payment_method, IS_INVALID_REPORT)
      end

    else
      if billing_type === BROKER_BILL
        errors.add(:payment_method, CANT_BE_BLANK_REPORT)
      end
    end
  end



  def customer_id_validations
    if customer_id.blank?
      errors.add(:customer_id, CANT_BE_BLANK_REPORT)
    end
  end



  def vehicle_validations
    if vehicle.blank?
      errors.add(:vehicle, CANT_BE_BLANK_REPORT)
    else
      if vehicle != (model_year.to_s + " " + make + " " + model)
        errors.add(:vehicle, IS_INVALID_REPORT)
      end
    end
  end



  def transferred_validations
    if transferred_premium.blank?
      errors.add(:transferred_premium, CANT_BE_BLANK_REPORT)
    else
      if transferred_id.blank? and transferred_premium != 0
        errors.add(:base, "Transferred premium can't be different from $0 if transferred_id is blank. #{REPORT}")
      end
    end
  end



  def policy_comments_validations
    if printed_agent_comments.present?
      max_length = 155
      if printed_agent_comments.length > max_length
        errors.add(:printed_agent_comments, "can't exceed #{max_length} characters.")
      end
    end
  end



  def agent_comments_validations
    if transaction_type === CANCELLED
      if agent_comments.blank?
        errors.add(:agent_comments, CANT_BE_BLANK)
      end
    end
  end



  def transaction_reason_validations
    if transaction_reason.present?
      if TRANSACTION_REASONS.include?(transaction_reason)
        policy = self.policy
        if get_permission_level(user_id,policy.broker_id) > UNDERWRITER_LEVEL and transaction_reason === CANCELLED_FOR_NON_PAYMENT
          errors.add(:transaction_reason, "can't be #{transaction_reason} due to your privilege level. #{REPORT}")
        end
      else
        errors.add(:transaction_reason, IS_INVALID_REPORT)
      end
    else
      errors.add(:transaction_reason, CANT_BE_BLANK_REPORT)
    end
  end



  def unpaid_balance_validations
    if billing_type === BROKER_BILL
      if unpaid_balance.blank?
        errors.add(:base, "Unpaid NSF Cheque Balance #{CANT_BE_BLANK}.")
      else
        if unpaid_balance.is_a?(Float) === false
          errors.add(:base, "Unpaid NSF Cheque Balance must be a float value. #{REPORT}")
        else
          if unpaid_balance < 0
            errors.add(:base, "Unpaid NSF Cheque Balance cannot be less than $0.")
          else
            transaction = Transaction.find_by(policy_id: id, transaction_type: "new")
            if transaction.present?
              total_premium = transaction.total_premium
              if total_premium.present? and unpaid_balance > total_premium
                errors.add(:base, "Unpaid NSF Cheque Balance cannot exceed #{total_premium}.")
              end
            end
          end
        end
      end
    end
  end

end