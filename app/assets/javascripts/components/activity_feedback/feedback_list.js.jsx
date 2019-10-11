window.ActivityFeedback || (window.ActivityFeedback = {});

window.ActivityFeedback.FeedbackList = class FeedbackList extends React.Component {

  propTypes: {
    feedbacks: PropTypes.array.isRequired,
    loading:   PropTypes.bool
  }

  _renderFeedback(feedback) {
    return <ActivityFeedback.Feedback key={feedback.id} feedback={feedback} />
  }

  render() {
    if (this.props.feedbacks.length === 0) {
      return (
        <div className={`results can-load`}>
          <div className="alert alert-info mb-0">
            { this.props.loading ? 'Loading ...' : 'No Results!' }
          </div>
        </div>
      );
    }

    return(
      <div className={`results can-load ${this.props.loading ? 'loading' : ''}`}>
        <ul className="list-group flat-list-group">
          { this.props.feedbacks.map(this._renderFeedback) }
        </ul>
        <ActivityFeedback.LoadMoreButton loading={this.props.loading}
                                         totalCount={this.props.meta.totalCount}
                                         loadedCount={this.props.feedbacks.length}
                                         onClick={this.props.handleNextPage} />
      </div>
    );
  }
}
