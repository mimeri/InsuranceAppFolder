class User < ApplicationRecord

  attr_accessor :remember_token,
                :password_confirmation

  has_many :transactions
  has_many :brokers
  has_many :employments

  has_paper_trail

  include PasswordValidations

  # def check_password_format
  #   regexps = {" must contain at least one lowercase letter" => /[a-z]+/,
  #              " must contain at least one digit" => /\d+/
  #   regexps.each do |rule, reg|
  #     errors.add(:password, rule) unless password.match(reg)
  #   end
  # end

  validates :name,
            presence: true,
            length: { maximum: 70 }

  validates :username,
            presence: true,
            length: { maximum: 70 },
            format: { without: /\s/ },
            uniqueness: true

  has_secure_password

  validate :password_validations

  # Returns the hash digest of the given string.
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
               BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # Returns a random token.
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  # Remembers a user in the database for use in persistent sessions.
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # Returns true if the given token matches the digest.
  def authenticated?(remember_token)
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  # Forgets a user.
  def forget
    update_attribute(:remember_digest, nil)
  end

end
