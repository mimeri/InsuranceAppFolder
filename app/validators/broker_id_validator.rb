class BrokerIdValidator < ActiveModel::EachValidator

  def validate_each(record, attribute, value)
    unless record.current_user.employments.pluck(:broker_id).include?(value.to_i)
      record.errors.add(:base, "ACCESS DENIED. You are attempting to get access to records belonging to a branch you are not part of. If you do belong to the branch you requested information on, please contact the administrator.")
    end
  end

end