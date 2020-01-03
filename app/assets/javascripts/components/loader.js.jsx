(() => {
  const LoadingIndicator = () => {
    return (
      <span className="loading-indicator">
        <i className="fa fa-sync-alt"></i>
      </span>
    )
  }

  window.LoadingIndicator = LoadingIndicator
}());

