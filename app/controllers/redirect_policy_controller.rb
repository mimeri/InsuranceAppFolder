require 'rest-client'

class RedirectPolicyController < ApplicationController

  include StringTemplates

  def show
    policy = Policy.find_by(quote_number: params[:id])
    if policy.present?
      if policy.payment_details_url.present?
        policy.update!(payment_details_url: nil)
        begin
          SnapMailer.activation_email(policy).deliver
        rescue Net::SMTPAuthenticationError, Net::SMTPServerBusy, Net::SMTPSyntaxError, Net::SMTPFatalError, Net::SMTPUnknownError => exception
          flash[:success] = "SNAP Payment Form successfully submitted"
          flash[:warning] = "Automatic activation email to SNAP failed to send. You will need to send this email manually. Reason for failure: #{exception.message}"
        else
          flash[:success] = "SNAP Payment Form successfully submitted. An automatic email has been sent to SNAP Financial requesting the activation of this policy."
        ensure
          redirect_to policy_detail_path(id: policy.id)
        end
      else
        flash[:danger] = "SNAP Payment Form submitted but you have already performed this operation. #{REPORT}"
        redirect_to policy_detail_path(id: policy.id)
      end
    else
      flash[:danger] = "SNAP Payment Form submitted but policy does not exist. #{REPORT}"
      redirect_to root_path
    end
  end
end
