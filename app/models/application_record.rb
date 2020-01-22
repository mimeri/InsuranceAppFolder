class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def normalize_blank_values
    attributes.each do |column, value|
      self[column].present? || self[column] = nil
    end
  end

end
