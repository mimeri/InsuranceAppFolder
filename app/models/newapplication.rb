class Newapplication < ApplicationRecord
  include CustomValidations
  belongs_to :user
  belongs_to :broker

  has_paper_trail

  validate :first_step_validations # from models/concerns/custom_validations.rb
  validate :second_step_validations # from models/concerns/custom_validations.rb
  validate :third_step_validations # from models/concerns/custom_validations.rb
  validate :fourth_step_validations # from models/concerns/custom_validations.rb
end

