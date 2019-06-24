# Allows RedCarpet to pass the _blank link attribute for markdown link rendering
# refer to solution at https://github.com/vmg/redcarpet/issues/85
class CompassMarkdownRenderer < Redcarpet::Render::HTML

  CALLOUT_REGEX = /\A\<h4\>(\w+)(\:\:[\S\s]+)?\<\/h4\>/

  def initialize(extensions = {})
    super extensions.merge(link_attributes: { target: "_blank" })
  end

  def table(header, body)
    "<table class=\"table table-bordered\">" \
      "#{header}#{body}" \
    "</table>"
  end

  def block_quote(quote)
    if matches = quote.match(CALLOUT_REGEX)
      icon_html = block_quote_icon_html(matches[1])
      tooltip_attrs = %(data-toggle="tooltip" title="#{matches[2][2..-1]}") if matches[2]
      %(
        <div class="callout callout-#{block_quote_class(matches[1])}">
          <div class="callout-icon" #{tooltip_attrs}>#{icon_html}</div>
          <div class="callout-body">
            #{quote.sub(CALLOUT_REGEX, '')}
          </div>
        </div>
      )
    else
      %(<blockquote>#{quote}</blockquote>)
    end
  end

  def block_code(code, lang)
    class_name = ""
    if lang
      ar = lang.split('-')
      class_name += "language-#{ar.first}" if ar.first != "selectable"
      class_name += " allow-select" unless ar.include?("nonselectable")
    end
    "<pre>" \
      "<code class='#{class_name}'>#{ERB::Util.html_escape(code)}</code>" \
    "</pre>"
  end

  def preprocess(doc)
    handle_toggle_code_block(doc)
    handle_toggle_markdown(doc)
  end

  private

  def handle_toggle_code_block(doc)
    regex = Regexp.new(/(^\?\?\?([a-zA-Z-]+)\s+(.*?)\s+^\?\?\?)/m)
    doc.gsub(regex) do
      code = Regexp.last_match[3]
      lang = Regexp.last_match[2]
      generate_toggle_block(block_code(code, lang))
    end
  end

  def handle_toggle_markdown(doc)
    regex = Regexp.new(/(^\?\?\?\?([A-Za-z0-9_\-]*)?\s+(.*?)\s+^\?\?\?\?)/m)
    doc.gsub(regex) do
      markdown_content = Regexp.last_match[3]
      id = Regexp.last_match[2]
      generate_toggle_markdown(markdown_content, id)
    end
  end

  def block_quote_class(type)
    case type.downcase
    when 'note', 'info'
      'info'
    when 'warning'
      'warning'
    when 'danger', 'alert'
      'danger'
    when 'question'
      'question'
    when 'instruction'
      'instruction'
    else
      'info'
    end
  end

  def block_quote_icon_html(type)
    type = type.downcase
    case type
    when 'note', 'info', 'information'
      %(
        <i class="fa fa-2x fa-info-circle"></i>
      )
    when 'warning'
      %(
        <i class="fa fa-2x fa-exclamation-triangle"></i>
      )
    when 'danger', 'alert'
      %(
        <i class="fa fa-2x fa-radiation-alt"></i>
      )
    when 'question'
      %(
        <i class="fa fa-2x fa-question-circle"></i>
      )
    when 'instruction'
      %(
        <i class="fa fa-2x fa-hand-point-right"></i>
      )
    else
      %(
        <span class="fa-stack">
          <i class="far fa-circle  fa-stack-2x"></i>
          <i class="fa fa-question fa-stack-1x"></i>
        </span>
      )
    end
  end

  def html_escape(string)
    string.gsub(/['&\"<>\/]/, '&' => '&amp;',
                              '<' => '&lt;',
                              '>' => '&gt;',
                              '"' => '&quot;',
                              "'" => '&#x27;',
                              "/" => '&#x2F;')
  end

  def generate_toggle_block(content)
    "<div class='togglable-solution'>" \
    "<div class='alert alert-success answer' role='alert' style='display: none;'>" \
    "#{content}" \
    "</div>" \
    "<a class='btn btn-primary' onclick='$(this).closest(\".togglable-solution\").find(\".answer\").toggle();'>Toggle Answer</a>" \
    "</div>"
  end

  def generate_toggle_markdown(content, id = nil)
    key = "data-key='#{id}'" if id.present?
    placeholder = "Type in your answer here before you can reveal it below. Your answer will auto-save as you type. Once you click 'Toggle Answer' below your answer cannot be changed."
    answer_textarea = "<label><strong>Your Answer</strong></label><textarea class='form-control mb-4 autosize' placeholder='#{placeholder}'></textarea>" if id.present?
    "<div class='togglable-solution card card-body mb-3' #{key}>" \
    "#{answer_textarea}" \
    "<div class='answer' style='display: none;'>" \
    "#{'<label><strong>Correct Answer</strong></label><br>' if id.present?}" \
    "#{markdown(content)}" \
    "</div>" \
    "<button class='btn btn-primary toggle-answer'>Toggle Answer</button>" \
    "</div>"
  end

  def markdown(content)
    return '' if content.nil?
    options = {
      autolink:            true,
      space_after_headers: true,
      fenced_code_blocks:  true,
      tables:              true,
      strikethrough:       true
    }
    Redcarpet::Markdown.new(CompassMarkdownRenderer, options).render(content)
  end

end
