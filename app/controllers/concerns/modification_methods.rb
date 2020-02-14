module ModificationMethods

  extend ActiveSupport::Concern

  def load_versions(policy)
    policy_created_at = policy.created_at

    versions_array = []

    item_id_and_type_hash = {policy.customer_id => Customer.model_name.name,
                             policy.id => Policy.model_name.name,
                             policy.transactions.find_by(transaction_type: "new").id => Transaction.model_name.name}

    cancelled_transaction = policy.transactions.find_by(transaction_type: CANCELLED)

    item_id_and_type_hash.store(cancelled_transaction.id, Transaction.model_name.name) unless cancelled_transaction.nil?

    item_id_and_type_hash.each do |item_id,item_type|
      version = PaperTrail::Version.where(item_id: item_id, item_type: item_type, created_at: (policy_created_at+1.second)..(Time.current))
      versions_array << version unless version.empty?
    end

    versions_array.flatten.sort_by!(&:created_at)
  end

end