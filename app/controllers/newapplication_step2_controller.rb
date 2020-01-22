class NewapplicationStep2Controller < ApplicationController

  include NewapplicationMethods

  before_action :populate_newapplication
  before_action :reserve_application, only: [:edit]


  def edit
  end

  def update
    if @newapplication.update newapplication_params.merge(form_step: form_step)
      if next?
        redirect_to edit_newapplication_step3_path(id: @newapplication.id)
      elsif previous?
        redirect_to edit_newapplication_step1_path(id: @newapplication.id)
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
    params.require(:newapplication).permit(:coverage_type,
                                           :policy_term,
                                           :oem_body_parts,
                                           :billing_type,
                                           :financing_term,
                                           :monthly_payment)
  end

  def form_step
    if save? || previous?
      'first'
    elsif next?
      'second'
    end
  end

end



