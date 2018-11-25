window.Queue || (window.Queue = {});

window.Queue.Location = class Location extends React.Component {
  propTypes: {
    location: PropTypes.object
  }

  render() {
    const loc = this.props.location;
    return (
      <div className="row queue-by-location">
        <div className="col-md-6">
          <h4>{loc.name} Queue</h4>
          <Queue.InProgressList assistances={loc.assistances || []} evaluations={loc.inProgressEvaluations || []} />
          <Queue.OpenRequestsList requests={loc.requests || []} />
          <Queue.PendingEvaluationsList evaluations={loc.pendingEvaluations || []} />
        </div>
        <div className="col-md-6">
          <h4>{loc.name} Students</h4>
          <Queue.StudentsList students={loc.students} />
        </div>
      </div>
    );
  }
}
