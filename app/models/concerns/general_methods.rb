require 'rest-client'

module GeneralMethods

  extend ActiveSupport::Concern

  include StringFunctions

  # Logs in the given user.
  def log_in(user)
    session[:user_id] = user.id
  end

  # Remembers a user in a persistent session.
  def remember(user)
    user.remember
    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  # Returns the user corresponding to the remember token cookie.
  def current_user
    if (user_id = session[:user_id])
      @current_user ||= User.find_by(id: user_id)
    elsif (user_id = cookies.signed[:user_id])
      user = User.find_by(id: user_id)
      if user && user.authenticated?(cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end

  # Returns true if the user is logged in, false otherwise.
  def logged_in?
    !current_user.nil?
  end

  # Forgets a persistent session.
  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  # Logs out the current user.
  def log_out
    forget(current_user)
    session.delete(:user_id)
    @current_user = nil
  end

  def get_user_name(id)
    if id.present?
      user = User.find_by id: id
      if user.present?
        user.name
      end
    end
  end

  def get_broker_name(broker_id)
    if broker_id.present?
      broker = Broker.where(id: broker_id).first
      if broker === nil
        "Error: Broker cannot be found in database. #{REPORT}"
      else
        broker.name
      end
    else
      raise "Error: broker_id not populated in this policy. #{REPORT}"
    end
  end

  def get_broker_phone(broker_id)
    if broker_id.present?
      broker = Broker.where(id: broker_id).first
      if broker === nil
        "Error: Broker cannot be found in database. #{REPORT}"
      else
        broker.phone
      end
    else
      raise "Error: broker_id not populated in this policy. #{REPORT}"
    end
  end

  def get_broker_id_list
    Employment.where(user_id: current_user.id).pluck(:broker_id)
  end

  def access_denied_broker(broker)
    broker_id_list = get_broker_id_list
    if broker_id_list.include?(broker) === false
      flash[:danger] = "ACCESS DENIED: Invalid Branch"
      redirect_to root_path
    end
  end

  def get_transferred_to(id)
    policy = Policy.find_by(transferred_id: id)
    if policy.present?
      policy.id
    end
  end

  def get_permission_level(user_id,broker_id)
    employment = Employment.find_by(user_id: user_id, broker_id: broker_id)
    if employment.present?
      employment.permission_level
    end
  end

  def is_valid_application_filter(filter_type)
    APPLICATION_DATE_FILTERS.values.include?(filter_type)
  end

  def is_valid_transaction_filter(filter_type)
    TRANSACTION_DATE_FILTERS.values.include?(filter_type)
  end

  def is_date(string)
    string.blank? or ((Date.parse string rescue nil).is_a?(Date))
  end

  def populate_if_date(string)
    if string.present? and is_date(string)
      string.to_date
    end
  end

  ############ SNAP METHODS, SHOULD MOVE TO NEW FILE SOON ##############################

  # returns hash
  def snap_api_call(url_string,xml_string)
    response_string = RestClient.post url_string, xml_string
    Hash.from_xml(Nokogiri::XML(response_string.body))
  end

  def get_account_is_successful(hash)
    hash.present? and hash["Response"]["IsSuccessful"] === "true"
  end

  def get_snap_account_status(hash)
    if hash.present?
      hash["Response"]["Data"]["Account"]["AccountStatus"]
    end
  end

  def get_snap_account_number(hash)
    if hash.present?
      hash["Response"]["Data"]["Account"]["AccountNumber"]
    end
  end

  def quote_import_is_successful(hash)
    hash.present? and hash["QuoteResponse"]["Errors"].blank?
  end

  #######################################################################################


end