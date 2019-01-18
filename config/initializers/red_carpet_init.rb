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

  # def block_code(code, language)
  #   "<code class=\"language-#{language}\">" \
  #     "#{code}" \
  #   "</code>"
  # end

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
    # raise full_document.inspect
    regex = Regexp.new(/(^\?\?\?([a-zA-Z-]+)\s+(.*?)\s+^\?\?\?)/m)
    # raise match[0].inspect if match
    doc.gsub(regex) do
      code = Regexp.last_match[3]
      lang = Regexp.last_match[2]
      generate_toggle_block(block_code(code, lang))
    end
  end

  private

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
    when 'note', 'info'
      %(
        <span class="fa-stack">
          <i class="fa fa-circle-o fa-stack-2x"></i>
          <i class="fa fa-info fa-stack-1x"></i>
        </span>
      )
    when 'warning'
      %(
        <span class="fa-stack">
          <i class="fa fa-circle-o fa-stack-2x"></i>
          <i class="fa fa-exclamation fa-stack-1x"></i>
        </span>
      )
    when 'danger', 'alert'
      %(
        <span class="fa-stack">
          <i class="fa fa-circle-o fa-rotate-90 fa-stack-2x"></i>
          <i class="fa fa-exclamation fa-stack-1x"></i>
        </span>
      )
    when 'question'
      %(
        <span class="fa-stack">
          <i class="fa fa-circle-o fa-stack-2x"></i>
          <i class="fa fa-question fa-stack-1x"></i>
        </span>
      )
    when 'instruction'
      %(
        <span class="fa-stack">
          <i class="fa fa-code fa-stack-2x"></i>
        </span>
      )
    else
      %(
        <span class="fa-stack">
          <i class="fa fa-circle-o fa-stack-2x"></i>
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

end
