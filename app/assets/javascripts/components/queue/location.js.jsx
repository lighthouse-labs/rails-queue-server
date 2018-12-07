window.Queue || (window.Queue = {});

window.Queue.Location = class Location extends React.Component {
  propTypes: {
    location: PropTypes.object
  }

  render() {
    const loc = this.props.location;
    return (
      <div className="row queue-by-location">
        <div className="col-lg-6">
          <Queue.OpenRequestsList requests={loc.requests || []} />
          <Queue.InProgressList assistances={loc.assistances || []} evaluations={loc.inProgressEvaluations || []} interviews={loc.inProgressInterviews || []} />
          <Queue.PendingEvaluationsList evaluations={loc.pendingEvaluations || []} />
          <Queue.InterviewStatusList cohorts={loc.interviewStatusesByCohort || []} students={loc.students} />
        </div>
        <div className="col-lg-6">
          <Queue.StudentsList students={loc.students} />
        </div>
      </div>
    );
  }
}
