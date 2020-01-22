class CheckForBlanksJob < ApplicationJob
  queue_as :default

  def perform(*args)
    customers = Customer.all
    policies = Policy.all
    transactions = Transaction.all
    hash = []
    hash << customers
    hash << policies
    hash << transactions

    hash.each do |h|
      h.each do |x|
        x.attributes.each do |column, value|
          if value.blank? and !value.nil?
            puts "#{column} is blank but not nil!"
          end
        end
      end
    end

  end
end
