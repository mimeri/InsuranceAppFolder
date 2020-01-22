class PolicyPfa < ApplicationRecord

  belongs_to :policy

  validates :pfa, presence: true
  validates :policy_id, presence: true

end
