class ModificationsController < ApplicationController

  include ModificationMethods

  def index
    @policy = Policy.find(params[:id])
    access_denied_broker(@policy.broker_id)
    @versions_array = load_versions(@policy)
  end

end