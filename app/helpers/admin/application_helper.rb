module Admin::ApplicationHelper
  def bg_gradient(status)
    case status
    when 'alerta'
      return 'bg-gradient-warning'
    when 'bloqueado'
      return "bg-gradient-danger"
    when 'normal'
      return "bg-gradient-primary"
    end
  end

  def formatted_text(text)
    html_content = ''
    lines = text.split("\n")

    lines.each_with_index do |line, line_index|
      line_html = ''

      segments = line.split(/(\*\*[^*]+\*\*)/).filter(&:present?)
      segments.each do |segment|
        if segment.start_with?('**') && segment.end_with?('**')
          content = segment[2...-2]
          line_html += content_tag(:b, content)
        else
          line_html += content_tag(:span, segment)
        end
      end

      line_html += tag.br unless line_index == lines.size - 1
      html_content += content_tag(:div, line_html.html_safe)
    end

    html_content.html_safe
  end
end
