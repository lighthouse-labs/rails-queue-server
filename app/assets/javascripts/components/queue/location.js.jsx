window.Queue || (window.Queue = {});

window.Queue.Location = class Location extends React.Component {
  propTypes: {
    location: PropTypes.object
  }

  render() {
    const loc = this.props.location;
    return (
      <div className="queue-by-location">
        <div className="row">
          <div className="col-lg-11">
            <Queue.OpenRequestsList requests={loc.requests || []} />
            <hr/>
          </div>
        </div>
        <div className="row">
          <div className="col-lg-6">
            <Queue.InProgressList assistances={loc.assistances || []} evaluations={loc.inProgressEvaluations || []} interviews={loc.inProgressInterviews || []} />
            <Queue.PendingEvaluationsList evaluations={loc.pendingEvaluations || []} />
            <Queue.InterviewStatusList cohorts={loc.interviewStatusesByCohort || []} students={loc.students} />
          </div>
          <div className="col-lg-5">
            <Queue.StudentsList students={loc.students} />
          </div>
        </div>
      </div>
    );
  }
}
