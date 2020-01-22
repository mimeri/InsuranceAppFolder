class NewapplicationStep3Controller < ApplicationController

  include NewapplicationMethods

  before_action :populate_newapplication
  before_action :reserve_application, only: [:edit]


  def edit
  end

  def update
    if @newapplication.update newapplication_params.merge(form_step: form_step)
      if next?
        redirect_to edit_newapplication_step4_path(id: @newapplication.id)
      elsif previous?
        redirect_to edit_newapplication_step2_path(id: @newapplication.id)
      elsif save?
        save_application(@newapplication.attributes["newapplication_id"],@newapplication.attributes,'Incomplete',false)
        redirect_to root_path
      end
    else
      render :edit
    end
  end

  #####################################################################################################

  private

  def newapplication_params
    params.require(:newapplication).permit(:insured_type,
                                           :first_name,
                                           :last_name,
                                           :address,
                                           :city,
                                           :province,
                                           :postal_code,
                                           :phone,
                                           :email,
                                           :make,
                                           :model,
                                           :vin,
                                           :reg_num,
                                           :lessor_name,
                                           :co_insured_first_name,
                                           :co_insured_last_name)
  end

  def form_step
    if save? || previous?
      'second'
    elsif next?
      'third'
    end
  end

end
