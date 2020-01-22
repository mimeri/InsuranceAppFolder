class DeleteNewapplicationFormsJob < ApplicationJob
  queue_as :default

  def perform(*args)
    NewapplicationForm.delete_all
  end

end
