class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :require_login, :set_cache_buster, :set_paper_trail_whodunnit
  auto_session_timeout 4.hours

  include GeneralMethods

  def set_cache_buster
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end

  private

    def user_params
      params.require(:user).permit(:name, :username, :password,
                                   :password_confirmation)
    end

    def require_login
      unless logged_in?
        redirect_to login_path
      end
    end

end
