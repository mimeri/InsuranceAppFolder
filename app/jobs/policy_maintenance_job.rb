class PolicyMaintenanceJob < ApplicationJob
  queue_as :default

  def perform(*args)
    Policy.all.each do |p|
      if p.unpaid_balance.blank?
        p.update!(unpaid_balance: 0)
      end
    end
  end

end
