class SessionsController < ApplicationController

  skip_before_action :require_login, only: [:new, :create]
  auto_session_timeout_actions

  def active
    render_session_status
  end

  def timeout
    render_session_timeout
  end

  def new
    if logged_in?
      redirect_to main_path
    end
    @no_header = true
    @no_footer = true
  end

  def create
    if browser.ie?
      flash[:danger] = "This application is not compatible with Internet Explorer, please use another browser."
      redirect_to login_path and return
    end

    user = User.find_by(username: params[:session][:username])
    if user && user.authenticate(params[:session][:password])
      log_in user
      params[:session][:remember_me] == '1' ? remember(user) : forget(user)
      redirect_to main_path    # need to change this
    else
      redirect_to login_path
      flash[:danger] = 'Invalid username/password combination'
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end
end
