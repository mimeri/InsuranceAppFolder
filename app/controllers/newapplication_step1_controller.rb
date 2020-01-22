class NewapplicationStep1Controller < ApplicationController

  include NewapplicationMethods

  before_action :populate_newapplication, only: [:edit,:update]
  before_action :reserve_application, only: [:edit]
  before_action :get_broker_list

  def new
    @newapplication = NewapplicationForm.new
  end

  def edit
    # see reserve_application
  end

  def update
    initial_steps
    if @newapplication.update newapplication_params.merge(form_step: form_step, user_id: current_user.id)
      if next?
        redirect_to edit_newapplication_step2_path(id: @newapplication.id)
      elsif save?
        save_application(@newapplication.attributes["newapplication_id"],@newapplication.attributes,'Incomplete',false)
        redirect_to root_path
      end
    else
      render :edit
    end
  end

  def create
    initial_steps
    if save?
      save_application(nil,newapplication_params,'Incomplete',false)
      redirect_to root_path
    elsif next?
      @newapplication = NewapplicationForm.new newapplication_params.merge(form_step: form_step, user_id: current_user.id)
      if @newapplication.save
        redirect_to edit_newapplication_step2_path(id: @newapplication.id)
      else
        render :new
      end
    end
  end

  #####################################################################################################

  private

    def newapplication_params
      params.require(:newapplication).permit(:broker_id,
                                             :model_year,
                                             :dealer_category,
                                             :dealer,
                                             :vehicle_price,
                                             :odometer,
                                             :use_rate_class,
                                             :gvw,
                                             :driver_factor).merge(purchase_date: @purchase_date)
    end

    def initial_steps
      get_purchase_date
      set_dealer(newapplication_params["dealer_category"])
      if newapplication_params["dealer_category"] === TESLA
        newapplication_params["make"] = TESLA
      end
    end

    def set_dealer(category)
      if category === PRIVATE_SALE
        newapplication_params["dealer"] = category
      elsif category === OUT_OF_PROVINCE
        newapplication_params["dealer"] = category
      end
    end

    def get_purchase_date
      @purchase_date = Date.civil(params[:newapplication]["purchase_date(1i)"].to_i,
                                  params[:newapplication]["purchase_date(2i)"].to_i,
                                  params[:newapplication]["purchase_date(3i)"].to_i)
    end

    def form_step
      if save?
        'none'
      elsif next?
        'first'
      end
    end

end
