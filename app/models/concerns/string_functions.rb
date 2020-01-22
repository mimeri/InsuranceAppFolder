module StringFunctions

  def upcase_field(field)
    if field.present?
      field.upcase
    else
      ""
    end
  end

  def format_phone(phone)
    string = ""
    if phone.present? and phone.length === 10
      string += "(" + phone[0,3] + ")-" + phone[3,3] + "-" + phone[6,4]
    end
    string
  end

end