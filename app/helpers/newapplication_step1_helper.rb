module NewapplicationStep1Helper

  def is_checked(from_newapplication,category)
    if from_newapplication.present?
      from_newapplication === category ? true : false
    else
      category === NOT_TESLA ? true : false
    end
  end

  def is_transferred
    (@newapplication.transferred_id.present? and @newapplication.broker_id.present?)
  end

end
