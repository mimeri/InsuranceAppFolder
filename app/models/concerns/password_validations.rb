module PasswordValidations
  extend ActiveSupport::Concern

  def password_validations
    if password.blank?
      errors.add(:password, CANT_BE_BLANK)
    else
      minimum_characters = 8
      if password.length < minimum_characters
        errors.add(:password, "is too short (minimum is #{minimum_characters} characters).")
      end
      errors.add(:password, "can't have any spaces.") if password.match(/\s/)
      errors.add(:password, "must contain at least one number") unless password.match(/\d/)
      errors.add(:password, "must contain at least one upper case alphabetic letter") unless password.match(/[A-Z]/)
      errors.add(:password, "must contain at least one lower case alphabetic letter") unless password.match(/[a-z]/)
    end
  end

end