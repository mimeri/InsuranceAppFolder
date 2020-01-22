class NewapplicationStep4Controller < ApplicationController

  include NewapplicationMethods

  before_action :populate_newapplication
  before_action :reserve_application, only: [:edit]


  def edit
  end

  def update
    if @newapplication.update newapplication_params.merge(form_step: form_step)
      if previous?
        redirect_to edit_newapplication_step3_path(id: @newapplication.id)
      else
        save_application_id = save_application(@newapplication.attributes["newapplication_id"],@newapplication.attributes,status,complete?)

        if complete?
          redirect_to bind_path(id: save_application_id)
        elsif save?
          redirect_to root_path
        end
      end
    else
      render :edit
    end
  end

  #####################################################################################################

  private

  def newapplication_params
    params.require(:newapplication).permit(:agent_comments)
  end

  def form_step
    if save? || previous?
      'third'
    elsif complete?
      'fourth'
    end
  end

  def status
    if complete?
      'Complete'
    elsif save?
      'Incomplete'
    end
  end

end
