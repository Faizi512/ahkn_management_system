module ReportsHelper
  def percentage(part, total)
    return 0 if total.zero?
    ((part.to_f / total) * 100).round(1)
  end

  def format_count(count)
    number_with_delimiter(count)
  end
end

