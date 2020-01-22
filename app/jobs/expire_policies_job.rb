class ExpirePoliciesJob < ApplicationJob

  queue_as :default

  def perform(*args)
    Policy.where(status: BOUND).each do |p|
      p.transactions.each do |t|
        if (t.expiry_date <= Time.current) and (t.transaction_type == "new")
          p.update!(status: EXPIRED)
        end
      end
    end
  end

end
