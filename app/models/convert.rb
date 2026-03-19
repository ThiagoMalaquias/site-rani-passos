class Convert
  def self.convert_comma_to_string(float_value)
    return "" if float_value.blank?

    ActiveSupport::NumberHelper.number_to_currency(float_value, unit: "", separator: ",", delimiter: ".")
  end

  def self.convert_comma_to_float(string_value)
    return 0 if string_value.blank?

    string_value.tr('.', '').tr(',', '.').to_f
  end
end
