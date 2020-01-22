class StaticPagesController < ApplicationController

  def home
  end

  def download
    pdf_location = "#{Rails.root}/lib/pdf_templates/#{download_params["download_form"]}.pdf"
    send_file pdf_location, type: 'application/pdf', disposition: 'inline'
  end

  private

  def download_params
    params.require(:download).permit(:download_form)
  end

end
