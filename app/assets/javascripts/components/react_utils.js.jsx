class ReactUtils {
  joinElements(elements, seperator=' ') {
    return elements.reduce((prev, curr) => [prev, seperator, curr])
  }

  renderQuote(quote, length=200) {
    return (<blockquote title={quote}>&ldquo;{_.truncate(quote, {length: length})}&rdquo;</blockquote>)
  }
}

window.App.ReactUtils = new ReactUtils();
