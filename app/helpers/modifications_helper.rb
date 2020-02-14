module ModificationsHelper

  def set_modification_page_header(object)
    get_type_of_transaction(object)+"#{object.item_type.capitalize} table modified at #{object.created_at.strftime("%b %-d, %Y %R")} by #{get_name_of_change_agent(object.whodunnit)}"
  end

  # If whodunnit field in versions table is nil, this means admin changed the database
  def get_name_of_change_agent(agent_id)
    string = get_user_name(agent_id)
    if agent_id.blank?
      string = "ADMIN ACTION"
    end
    string
  end

  # If table is a Transaction table, need to distinguish between 'New Policy Transaction' and 'Cancellation Transaction'
  def get_type_of_transaction(object)
    type_string = ""
    if object.item_type === Transaction.model_name.name
      if object.reify.transaction_type === "new"
        type_string += "New policy "
      elsif object.reify.transaction_type === CANCELLED
        type_string += "Cancellation "
      end
    end
    type_string
  end

end
