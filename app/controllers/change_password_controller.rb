class ChangePasswordController < ApplicationController

  def new
    @user = User.new
  end

  def create
    @user = current_user
    if @user.authenticate(change_password_params["current_password"])
      if same_password
        flash.now[:danger] = "New password must not be the same as the current password"
        render :new
      else
        if @user.update change_password_params.except(:current_password)
          flash[:success] = "Password successfully changed"
          redirect_to root_path
        else
          render :new
        end
      end
    else
      flash.now[:danger] = "Current password is incorrect."
      render :new
    end
  end

  private

    def change_password_params
      params.require(:change_password).permit(:current_password,
                                              :password,
                                              :password_confirmation)
    end

    def same_password
      @user.authenticate(change_password_params["password"])
    end

end
