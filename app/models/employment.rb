class Employment < ApplicationRecord
  belongs_to :broker
  belongs_to :user
end