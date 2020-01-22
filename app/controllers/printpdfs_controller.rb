require 'base64'

class PrintpdfsController < ApplicationController

  include GeneralModelMethods

  def update
    policy = Policy.find(printpdf_params["id"])

    pdf = CombinePDF.new

    tmp_file_array = []

    if requested_new_broker
      pdf_to_load = PrintNewCertificate.new(policy,"broker").export("certificateofinsurance")
      pdf << CombinePDF.load(pdf_to_load)
      tmp_file_array << pdf_to_load
      add_void_watermark(pdf,policy.status)
    end

    if requested_new_insured
      pdf_to_load = PrintNewCertificate.new(policy,"insured").export("certificateofinsurance")
      pdf << CombinePDF.load(pdf_to_load)
      tmp_file_array << pdf_to_load
      add_void_watermark(pdf,policy.status)
      pdf << CombinePDF.load("#{Rails.root}/lib/pdf_templates/rest_of_insured_copy.pdf")
    end

    if policy.transactions.where(transaction_type: CANCELLED).present?
      if requested_cancelled_broker
        pdf_to_load = PrintCancellationCertificate.new(policy,"broker").export("certificateofcancellation")
        pdf << CombinePDF.load(pdf_to_load)
        tmp_file_array << pdf_to_load
      end

      if requested_cancelled_insured
        pdf_to_load = PrintCancellationCertificate.new(policy,"insured").export("certificateofcancellation")
        pdf << CombinePDF.load(pdf_to_load)
        tmp_file_array << pdf_to_load
      end
    end

    if requested_financing_contract and policy.billing_type === DIRECT_BILL
      policy_pfa = PolicyPfa.where(policy_id: policy.id).first
      if policy_pfa.present?
        if policy_pfa.pfa.present?
          pfa = policy_pfa.pfa
          decoded_pfa = Base64.decode64(pfa)
          pdf_to_load = "#{Rails.root}/tmp/pdfs/#{SecureRandom.uuid}.pdf"
          File.open(pdf_to_load,"wb") do |f|
            f.write(decoded_pfa)
          end
          pdf << CombinePDF.load(pdf_to_load)
          tmp_file_array << pdf_to_load
        end
      else
        raise 'Error (policy_pfa blank). Could not generate financing contract form. Please report this error to the administrator'
      end
    end

    if requested_release_of_interest
      pdf_to_load = PrintReleaseOfInterest.new(policy).export("release_of_interest")
      pdf << CombinePDF.load(pdf_to_load)
      tmp_file_array << pdf_to_load
    end

    combined_pdf_location = "#{Rails.root}/tmp/combined_pdfs/#{SecureRandom.uuid}.pdf"

    pdf.save combined_pdf_location

    tmp_file_array.each do |t|
      File.delete(t)
    end

    send_file combined_pdf_location, type: 'application/pdf', disposition: 'inline'
  end

  def print_modified
    version = PaperTrail::Version.find(modified_printpdf_params["version_id"])
    transaction_id = modified_printpdf_params["transaction_id"]
    policy_id = modified_printpdf_params["policy_id"]
    customer_id = modified_printpdf_params["customer_id"]
    id_array = [transaction_id,policy_id,customer_id]
    model_name_array = [Transaction.model_name.name, Policy.model_name.name, Customer.model_name.name]
    object_array = [version.reify]
    count = 0
    model_name_array.each do |model_name|
      if model_name != version.item_type
        element = PaperTrail::Version.where(item_id: id_array[count], item_type: model_name, created_at: (version.created_at)..(Time.current)).first
        if element.blank?
          element = model_name.constantize.find(id_array[count])
        else
          element = element.reify
        end
        object_array << element
      end
      count += 1
    end
    fields = merge_three_objects(object_array[0],object_array[1],object_array[2])

    pdf = CombinePDF.new
    pdf_to_load = PrintModifiedCertificate.new(fields).export("certificateofinsurance")
    pdf << CombinePDF.load(pdf_to_load)

    combined_pdf_location = "#{Rails.root}/tmp/combined_pdfs/#{SecureRandom.uuid}.pdf"
    pdf.save combined_pdf_location
    File.delete(pdf_to_load)
    send_file combined_pdf_location, type: 'application/pdf', disposition: 'inline'
  end

  private

    def printpdf_params
      params.require(:printpdf).permit(:id, :broker_check, :insured_check, :cancellation_broker_check, :cancellation_insured_check, :financing_contract_form)
    end

    def modified_printpdf_params
      params.require(:modified_printpdf).permit(:version_id, :transaction_id, :policy_id, :customer_id)
    end

    def requested_modified_new_broker
      params[:modified_printpdf][:broker_check] === '1'
    end

    def requested_new_broker
      params[:printpdf][:broker_check] === '1'
    end

    def requested_new_insured
      params[:printpdf][:insured_check] === '1'
    end

    def requested_cancelled_broker
      params[:printpdf][:cancellation_broker_check] === '1'
    end

    def requested_cancelled_insured
      params[:printpdf][:cancellation_insured_check] === '1'
    end

    def requested_financing_contract
      params[:printpdf][:financing_contract_form] == '1'
    end

    def requested_release_of_interest
      params[:printpdf][:release_of_interest] == '1'
    end

    def add_void_watermark(pdf,status)
      if status === VOID
        void_watermark = CombinePDF.load("#{Rails.root}/lib/pdf_templates/void.pdf", allow_optional_content: true).pages[0]
        pdf.pages.last << void_watermark
      end
    end

end
