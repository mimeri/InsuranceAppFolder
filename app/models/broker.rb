class Broker < ApplicationRecord
  has_many :newapplication_forms
  has_many :newapplications
  has_many :users
  has_many :employments
end
