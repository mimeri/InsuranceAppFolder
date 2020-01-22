class NewapplicationForm < ApplicationRecord

  include CustomValidations

  cattr_accessor :form_steps do
    %w(none first second third fourth)
  end

  attr_accessor :form_step

  def required_for_step?(step)
    true if form_step.nil? || self.form_steps.index(step.to_s) <= self.form_steps.index(form_step)
  end

  with_options if: -> {required_for_step?(:first)} do
    validate :first_step_validations # from models/concerns/custom_validations.rb
  end

  # step 2 - coverage details
  with_options if: -> {required_for_step?(:second)} do
    validate :second_step_validations # from models/concerns/custom_validations.rb
  end

  # step 3 - insured and vehicle details
  with_options if: -> {required_for_step?(:third)} do
    validate :third_step_validations # from models/concerns/custom_validations.rb
  end

  #step 4 - review
  with_options if: -> {required_for_step?(:fourth)} do
    validate :fourth_step_validations # from models/concerns/custom_validations.rb
  end

end
