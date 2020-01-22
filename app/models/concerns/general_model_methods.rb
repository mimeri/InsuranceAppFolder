module GeneralModelMethods

  extend ActiveSupport::Concern

  include ActiveModel::Model

  def merge_three_objects(obj1,obj2,obj3)
    obj1.attributes.merge(obj2.attributes.except("id"),obj3.attributes.except("id"))
  end

end