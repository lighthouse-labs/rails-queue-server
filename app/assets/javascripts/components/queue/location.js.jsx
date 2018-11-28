window.Queue || (window.Queue = {});

window.Queue.Location = class Location extends React.Component {
  propTypes: {
    location: PropTypes.object
  }

  render() {
    const loc = this.props.location;
    return (
      <div className="row queue-by-location">
        <div className="col-md-12">
          <h4>{loc.name} Queue</h4>
        </div>
        <div className="col-md-6 order-1 order-md-1">
          <Queue.OpenRequestsList requests={loc.requests || []} />
          <Queue.InProgressList assistances={loc.assistances || []} evaluations={loc.inProgressEvaluations || []} interviews={loc.inProgressInterviews || []} />
          <Queue.PendingEvaluationsList evaluations={loc.pendingEvaluations || []} />
        </div>
        <div className="col-md-6 order-2 order-md-2">
          <Queue.StudentsList students={loc.students} />
        </div>
      </div>
    );
  }
}
