class ReactUtils {
  joinElements(elements, seperator=' ') {
    return elements.reduce((prev, curr) => [prev, seperator, curr]);
  }

  renderQuote(quote, length=200) {
    if (quote && _.trim(quote).length > 0) {
      return (
        <blockquote title={quote}>
          &ldquo;{_.truncate(quote, {length: length})}&rdquo;
        </blockquote>
      );
    }
  }

  renderActivityDetails(activity) {
    if (!activity) return;
    return (
      <a className="resource-name" href={`/${activity.uuid}`}>{activity.name}</a>
    );
  }
}

window.App.ReactUtils = new ReactUtils();
