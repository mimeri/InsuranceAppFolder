class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  # Removed from default: :registerable, :recoverable, :rememberable, :validatable
  devise :database_authenticatable, :lockable, :timeoutable, :trackable

  has_many :transactions
  has_many :brokers
  has_many :employments

  has_paper_trail

  include PasswordValidations

  validates :name,
            presence: true,
            length: { maximum: 70 }

  validates :username,
            presence: true,
            length: { maximum: 70 },
            format: { without: /\s/ },
            uniqueness: true

  validate :password_validations

end
