class SnapMailer < ApplicationMailer

  default from: -> {"haywardpos@gmail.com"},
          reply_to: -> {SNAP_REPLY_TO}

  def activation_email(policy)
    @quote_number = policy.quote_number
    @policy_number = policy.id

    pdf = CombinePDF.new
    pdf_to_load = PrintNewCertificate.new(policy, "broker").export("certificateofinsurance")
    pdf << CombinePDF.load(pdf_to_load)
    combined_pdf_location = "#{Rails.root}/tmp/combined_pdfs/#{SecureRandom.uuid}.pdf"
    pdf.save combined_pdf_location
    attachments['certificate_of_insurance.pdf'] = File.read(combined_pdf_location)
    mail(to: SNAP_EMAIL_ADDRESS, subject: "[Hayward Insurance] Activate policy with QuoteNumber: #{@quote_number} and PolicyNumber: #{@policy_number}")
    File.delete(pdf_to_load)
    File.delete(combined_pdf_location)
  end

  def cancellation_email(policy)
    @account_number = policy.snap_account_number

    pdf = CombinePDF.new
    pdf_to_load = PrintCancellationCertificate.new(policy, "broker").export("certificateofcancellation")
    pdf << CombinePDF.load(pdf_to_load)
    combined_pdf_location = "#{Rails.root}/tmp/combined_pdfs/#{SecureRandom.uuid}.pdf"
    pdf.save combined_pdf_location
    attachments['certificate_of_cancellation.pdf'] = File.read(combined_pdf_location)
    mail(to: SNAP_EMAIL_ADDRESS, subject: "[Hayward Insurance] Cancel policy with AccountNumber: #{@account_number}")
    File.delete(pdf_to_load)
    File.delete(combined_pdf_location)
  end

  def alert_email(body)
    mail(to: "imerimario@gmail.com",
         subject: "Unexpected Result From SNAP",
         body: body,
         content_type: "text/html")
  end

end