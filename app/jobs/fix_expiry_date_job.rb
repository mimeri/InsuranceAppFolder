class FixExpiryDateJob < ApplicationJob
  queue_as :default

  def perform(*args)
    cancelled_transactions = Transaction.where(transaction_type: CANCELLED)
    cancelled_transactions.each do |c|
      new_transaction = Transaction.find_by(transaction_type: "new", policy_id: c.policy_id)
      if new_transaction.expiry_date != c.expiry_date
        puts "new expiry_date: #{new_transaction.expiry_date}"
        puts "cancelled expiry_date before: #{c.expiry_date}"
        c.update!(expiry_date: new_transaction.expiry_date)
        puts "cancelled expiry_date after: #{c.expiry_date}"
      end
    end
  end

end
