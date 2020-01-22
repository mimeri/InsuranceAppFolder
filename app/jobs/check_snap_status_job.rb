class CheckSnapStatusJob < ApplicationJob
  queue_as :default

  include StringTemplates
  include GeneralMethods

  def perform(*args)
    policies = Policy.where(billing_type: DIRECT_BILL)
    policies.each do |p|
      if p.quote_number.present?
        xml_string = get_account_xml(p.quote_number)
        hash = snap_api_call(GET_ACCOUNT_URL, xml_string)
        if get_account_is_successful(hash)
          # this likely means SNAP status is Current or Cancelled
          snap_account_status = get_snap_account_status(hash)
          if snap_account_status.present?
            if snap_account_status === "Current"
              p.update_snap_status
            elsif snap_account_status === "Cancelled"
              if p.snap_status_is_not_active or p.snap_status_is_active
                SnapMailer.alert_email("From CheckSnapStatusJob Error #1. Policy with ID: #{p.id} has snap_status = #{p.snap_status} and from SNAP the status is #{snap_account_status} at #{Time.current.to_s}").deliver
              end
            end
          else
            SnapMailer.alert_email("From CheckSnapStatusJob. Error #2. Policy with ID: #{p.id} at #{Time.current.to_s}").deliver
          end
        else
          # this means account is not yet activated
          if p.snap_status_is_active or p.snap_status_is_cancelled
            SnapMailer.alert_email("From CheckSnapStatusJob. Policy with ID: #{p.id} has snap_status = #{p.snap_status} but is inactive at SNAP at #{Time.current.to_s}").deliver
          end
        end
      else
        SnapMailer.alert_email("From CheckSnapStatusJob. Error #3. Policy with ID: #{p.id}").deliver
      end
    end
  end
end
