window.Queue || (window.Queue = {});

window.Queue.OpenRequestsList = class OpenRequestsList extends React.Component {
  propTypes: {
    requests: PropTypes.array
  }

  renderRequest(request) {
    // if(task.type === 'Evaluation') {
    //   return <Queue.PendingEvaluation key={`evaluation-${task.id}`} evaluation={task} />
    // } else if (task.type === 'Assistance') {
      return <Queue.PendingAssistanceRequest key={`request-${request.id}`} request={request} />
    // } else if (task.type === 'Interview') {
    //    return <Queue.PendingInterview key={`interview-${task.id}`} interview={task} />
    // }
  }

  renderRequests() {
    return this.props.requests.map(this.renderRequest);
  }

  render() {
    return (
      <div className="card card-default">
        <div className="card-header clearfix">
          <h5 className="card-title">
            <span className="count">{this.props.requests.length}</span>
            <span className="title">Open Help Requests</span>
          </h5>
        </div>
        <ul className="list-group">
          {this.renderRequests()}
        </ul>
      </div>
    );
  }
}

