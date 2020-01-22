class Transaction < ApplicationRecord

  include CustomValidations
  belongs_to :policy
  belongs_to :user
  has_paper_trail on: [:update], only: [:agent_comments]

  before_save :normalize_blank_values

  #step 1
  validate :effective_date_validations, on: :create

  #step 2
  validate :expiry_date_validations, on: :create

  validate :user_id_validations, on: :create

  validate :agent_comments_validations

  validate :transaction_reason_validations, on: :create

end
