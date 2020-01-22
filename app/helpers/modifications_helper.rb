module ModificationsHelper

  def load_versions
    versions_array = []
    policy_created_at = @policy.created_at

    customer_versions = PaperTrail::Version.where(item_id: @policy.customer.id, item_type: Customer.model_name.name, created_at: (policy_created_at+1.second)..(Time.current))
    policy_versions = PaperTrail::Version.where(item_id: @policy.id, item_type: Policy.model_name.name, created_at: (policy_created_at+1.second)..(Time.current))
    new_transaction_versions = PaperTrail::Version.where(item_id: @new_transaction.id, item_type: Transaction.model_name.name, created_at: (policy_created_at+1.second)..(Time.current))
    cancelled_transaction_versions = nil
    if @cancelled_transaction.present?
      cancelled_transaction_versions = PaperTrail::Version.where(item_id: @cancelled_transaction.id, item_type: Transaction.model_name.name, created_at: (policy_created_at+1.second)..(Time.current))
    end

    objects_array_to_add = [customer_versions,policy_versions,new_transaction_versions,cancelled_transaction_versions]
    objects_array_to_add.each do |object|
      if object.present?
        versions_array << object
      end
    end

    versions_array = versions_array.flatten
    versions_array.sort_by!(&:created_at)
    versions_array
  end

  def field_changed(current_field,current_version,current_object)
    next_version = current_version.next
    current_version = current_version.reify
    if next_version.present?
      next_version = next_version.reify
      if current_version[current_field] != next_version[current_field]
        "#{next_version[current_field]}"
      else
        nil
      end
    else
      if current_version[current_field] != current_object[current_field]
        "#{current_object[current_field]}"
      else
        nil
      end
    end
  end

end
