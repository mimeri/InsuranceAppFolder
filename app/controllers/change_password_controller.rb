class ChangePasswordController < ApplicationController

  def edit
    @user = current_user
  end

  def update
    @user = current_user

    if @user.valid_password?(change_password_params["password"]) and @user.valid_password?(change_password_params["current_password"])
      @user.errors.add(:base, 'New password must not be the same as the current password')
      render :edit
    elsif @user.update_with_password(change_password_params)
      bypass_sign_in(@user)
      flash[:success] = "Password successfully changed"
      redirect_to root_path
    else
      render :edit
    end

  end

  private

  def change_password_params
    params.require(:change_password).permit(:current_password, :password)
  end

end
