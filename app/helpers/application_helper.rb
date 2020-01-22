module ApplicationHelper

  # Returns the full title on a per-page basis.
  def full_title(page_title = '')
    base_title = "Hayward Insurance Brokers POS"
    if page_title.empty?
      base_title
    else
      page_title + " | " + base_title
    end
  end

  # Checks that current path is in newapplication
  def is_newapplication_path(id)
    current_uri = request.env['PATH_INFO']
    valid_paths = ['/newapplication_step2/'+id.to_s,'newapplication_step3/'+id.to_s,'newapplication_step4/'+id.to_s]
    valid_paths.include?(current_uri)
  end

end