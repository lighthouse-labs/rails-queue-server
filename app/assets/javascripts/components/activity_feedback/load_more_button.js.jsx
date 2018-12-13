window.ActivityFeedback || (window.ActivityFeedback = {});

window.ActivityFeedback.LoadMoreButton = class LoadMoreButton extends React.Component {

  propTypes: {
    loading:     PropTypes.bool.isRequired,
    totalCount:  PropTypes.number.isRequired,
    loadedCount: PropTypes.number.isRequired,
    onClick:     PropTypes.func.isRequired
  }

  _renderButton() {
    if (this.props.loading) {
      return <button className="btn btn-outline-primary disabled">Loading</button>
    }

    const left = this.props.totalCount - this.props.loadedCount;
    if (left > 0) {
      return(
        <button className="btn btn-primary" onClick={this.props.onClick}>
          Load 25 More ({left} left)
        </button>
      );
    }

    // Otherwise there's nothing to load :)

    return <button className="btn btn-light disabled">No More To Load</button>
  }

  render() {
    return (
      <div className="btn-toolbar" role="toolbar">
        <div className="btn-group mr-auto mb-2 mt-2 ml-auto" role="group" aria-label="Load More">
          { this._renderButton() }
        </div>
      </div>
    );
  }

}