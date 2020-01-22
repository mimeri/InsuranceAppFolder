module NewapplicationMethods

  extend ActiveSupport::Concern

  include GeneralMethods

  def save_application(id,attributes,status,will_validate)

    attributes_id = attributes["id"]

    full_name = set_full_name(attributes["first_name"],attributes["last_name"])
    vehicle = set_vehicle(attributes["model_year"],attributes["make"],attributes["model"])

    new_attributes = attributes.merge(status: status, name: full_name, vehicle: vehicle, user_id: current_user.id).except("form_step","newapplication_id")

    if id.present?
      new_application = Newapplication.find(id)
      new_application.attributes = new_attributes
      new_application.id = id
    else
      new_application = Newapplication.new new_attributes.except("id")
    end

    new_application.save!(validate: will_validate)
    NewapplicationForm.delete(attributes_id)
    new_application.id
  end

  def previous?
    params[:commit] === '<< Previous'
  end

  def next?
    params[:commit] === 'Next >>'
  end

  def save?
    params[:commit] === 'Save'
  end

  def complete?
    params[:commit] === 'Complete'
  end

  def get_broker_list
    broker_id_list = get_broker_id_list
    @broker = []
    broker_id_list.each do |b|
      @broker << Broker.find(b)
    end
  end


  def reserve_application
    if @newapplication.user_id.present?
      if @newapplication.user_id != current_user.id

        flash[:danger] = "ACCESS DENIED: You are attempting to access a NewapplicationForm object that you did not create.
                            You are likely encountering this error because you attempted to access a record through direct URL.
                            If this is not the case please screenshot this page and report to the administrator."
        redirect_to root_path
      end
    end
  end

  def set_full_name(first_name,last_name)
    return_value = ""
    if first_name.present?
      return_value += first_name
      if last_name.present?
        return_value += " #{last_name}"
      end
    end
    return_value
  end

  def set_vehicle(model_year,make,model)
    if model_year.present?
      model_year = model_year.to_s
    end
    return_value = ""
    return_value += model_year unless model_year.blank?
    return_value += " " if (model_year.present? and make.present?)
    return_value += make unless make.blank?
    return_value += " " if (model.present? and (model_year.present? or make.present?))
    return_value += model unless model.blank?
    return_value
  end

  def populate_newapplication
    @newapplication = NewapplicationForm.find_by id: params[:id]
    if @newapplication.blank?
      redirect_to root_path
    end
  end

end