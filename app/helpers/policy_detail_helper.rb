module PolicyDetailHelper

  include CancellationMethods

  def get_user_name(id)
    if id.present?
      user = User.find_by id: id
      if user.present?
        user.name
      end
    end
  end

  def get_policy_details_header
    policy_details_header = ""
    if (@policy.is_bound) and (Date.current < @new_transaction.expiry_date)
      policy_details_header += "effective " + @new_transaction.effective_date.strftime("%b %-d, %Y").to_s + " to " + @new_transaction.expiry_date.strftime("%b %-d, %Y").to_s
    elsif (@policy.is_expired) or (Date.current > @new_transaction.expiry_date.to_date)
      policy_details_header += "#{EXPIRED} " + @new_transaction.expiry_date.strftime("%b %-d, %Y").to_s
    elsif [CANCELLED,VOID,TRANSFERRED].include?(@policy.status)
      policy_details_header += "#{@policy.status} on " + @cancelled_transaction.effective_date.strftime("%b %-d, %Y").to_s
    else
      policy_details_header += "Error occurred. #{REPORT}"
    end
    policy_details_header
  end

  def get_transaction_type(type)
    if type === "new"
      "New policy"
    elsif type === CANCELLED
      "Cancellation"
    else
      "Error occurred. #{REPORT}"
    end
  end

  def get_days_active
    if @policy.is_bound
      (Date.current - @new_transaction.effective_date).to_i
    elsif @policy.is_expired
      (@new_transaction.expiry_date - @new_transaction.effective_date).to_i
    else
      (@cancelled_transaction.effective_date - @new_transaction.effective_date).to_i
    end
  end

  def has_modification
    object_array = [@policy.customer,@policy,@new_transaction,@cancelled_transaction]
    object_array.each do |element|
      if element.present?
        version_array = element.versions
        if (version_array.count > 0) and (version_array.last.created_at > @policy.created_at)
          return true
        end
      end
    end
    false
  end

  def policy_is_active
    (@policy.is_bound) and ((@new_transaction.expiry_date - Date.current).to_i > CANT_CANCEL_B4_EXPIRATION)
  end

  def enable_button(bool)
    if bool
      ""
    else
      "disabled"
    end
  end

end
