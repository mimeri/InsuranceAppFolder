module SeedingMethods

  extend ActiveSupport::Concern

  def seed_newapplications(number)

    number.times do
      newapplication = Newapplication.new(
          model_year: Faker::Number.between(2018,2019),
          purchase_date: Faker::Date.between(Date.current.beginning_of_year,Date.current-30),
          dealer_category: [TESLA,NOT_TESLA,OUT_OF_PROVINCE,PRIVATE_SALE].sample,
          vehicle_price: Faker::Number.between(30000,149000),
          odometer: Faker::Number.between(1000,40000),
          use_rate_class: ['001 - PLEASURE USE',
                           '002 - OVER 15 km TO WORK',
                           '003 - UNDER 15 km TO WORK',
                           '004 - P/T PUBLIC TRANSIT',
                           '007 - BUSINESS USE',
                           '011 - FARM USE',
                           '012 - ARTISAN USE',
                           '014 - FISHER USE'].sample,
          driver_factor: Faker::Number.between(0,0.999).round(3),
          coverage_type: [FULL_REPLACEMENT,LIMITED_DEPRECIATION].sample,
          policy_term: ["5 years","4 years","3 years","2 years"].sample,
          billing_type: [BROKER_BILL,DIRECT_BILL].sample,
          address: Faker::Address.street_address,
          city: Faker::Address.city,
          province: "BC",
          postal_code: "V3B8S2",
          phone: Faker::Number.between(6042000000,6049999999),
          email: Faker::Internet.email,
          make: Faker::Vehicle.make,
          vin: Faker::Vehicle.vin,
          reg_num: Faker::Number.between(11111111,99999999),
          lessor_name: Faker::Company.name,
          co_insured_first_name: Faker::Name.first_name,
          co_insured_last_name: Faker::Name.last_name,
          agent_comments: Faker::Movies::HarryPotter.quote[0,150],
          status: ["Complete","Incomplete"].sample,
          user_id: User.ids.sample)

      newapplication.insured_type = ["Person","Company"].sample
      if newapplication.billing_type === DIRECT_BILL
        newapplication.insured_type = "Person"
      end

      newapplication.broker_id = 1

      if newapplication.dealer_category === TESLA
        newapplication.dealer = "Tesla Dealership"
        newapplication.make = TESLA
      elsif newapplication.dealer_category === NOT_TESLA
        newapplication.dealer = "Not Tesla Dealership example"
      end

      if newapplication.dealer_category === TESLA
        newapplication.model = ["3","S","X","Y","Roadster"].sample
      else
        newapplication.model = Faker::Vehicle.model(newapplication.make)
      end

      if newapplication.insured_type === "Person"
        newapplication.first_name = Faker::Name.first_name
        newapplication.last_name = Faker::Name.last_name
      elsif newapplication.insured_type === "Company"
        newapplication.first_name = Faker::Company.name
        newapplication.last_name = nil
      end

      @non_gvw_classes = ['',
                          '001 - PLEASURE USE',
                          '002 - OVER 15 km TO WORK',
                          '003 - UNDER 15 km TO WORK',
                          '004 - P/T PUBLIC TRANSIT',
                          '007 - BUSINESS USE']

      @gvw_classes = ['011 - FARM USE',
                      '012 - ARTISAN USE',
                      '014 - FISHER USE']

      use_rate_class_string = newapplication.use_rate_class
      if @non_gvw_classes.include?(use_rate_class_string)
        newapplication.gvw = nil
      elsif @gvw_classes.include?(use_rate_class_string)
        newapplication.gvw = Faker::Number.between(1,4999)
      end

      while newapplication.vin !~ /^[a-hj-npr-zA-HJ-NPR-Z0-9]+$/
        newapplication.vin = Faker::Vehicle.vin
      end

      if newapplication.billing_type === DIRECT_BILL
        if newapplication.policy_term === "5 years"
          newapplication.financing_term = ["48 months","36 months","24 months"].sample
        elsif newapplication.policy_term === "4 years"
          newapplication.financing_term = ["36 months","24 months"].sample
        elsif newapplication.policy_term === "3 years"
          newapplication.financing_term = "24 months"
        elsif newapplication.policy_term === "2 years"
          newapplication.financing_term = "12 months"
        end
      end

      if newapplication.coverage_type === FULL_REPLACEMENT and newapplication.model_year >= (Date.current.year - 1)
        if newapplication.policy_term != "2 years"
          newapplication.oem_body_parts = YES_3_YEARS
        else
          newapplication.oem_body_parts = YES_2_YEARS
        end
      else
        newapplication.oem_body_parts = NOT_ELIGIBLE
      end

      name_string = ""
      name_string += newapplication.first_name unless newapplication.first_name.blank?
      name_string += (" " + newapplication.last_name) unless (newapplication.first_name.blank? or newapplication.last_name.blank? or newapplication.insured_type === "Company")
      newapplication.name = name_string

      vehicle_string = ""
      vehicle_string += newapplication.model_year.to_s unless newapplication.model_year.blank?
      vehicle_string += (" " + newapplication.make) unless newapplication.make.blank?
      vehicle_string += (" " + newapplication.model) unless newapplication.model.blank?
      newapplication.vehicle = vehicle_string

      have_co_applications = [true,false].sample
      if have_co_applications === false
        newapplication.co_insured_first_name = nil
        newapplication.co_insured_last_name = nil
      end

      have_lessor = [true,false].sample
      if have_lessor === false
        newapplication.lessor_name = nil
      end

      newapplication.save!(validate: false)

      newapplication.created_at = rand(newapplication.purchase_date.beginning_of_day..Date.current.beginning_of_day)
      newapplication.updated_at = newapplication.created_at
      newapplication.save!(validate: false)
    end
  end

end