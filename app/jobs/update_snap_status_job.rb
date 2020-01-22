require 'rest-client'

class UpdateSnapStatusJob < ApplicationJob
  queue_as :default

  include GeneralMethods
  include StringTemplates

  def perform(*args)
    all_policies = Policy.where(billing_type: DIRECT_BILL)
    all_policies.each do |p|
      p.update_snap_status
    end
  end

end