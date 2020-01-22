module BindHelper

  def get_policy_id_with_same_name(name)
    policy = PolicyQuery.new.find_by_name(name)
    if policy.present?
      policy.id
    end
  end

end
