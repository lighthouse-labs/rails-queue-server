window.Queue || (window.Queue = {});

window.Queue.CohortInterviewStatuses = class CohortInterviewStatuses extends React.Component {
  propTypes: {
    cohort: PropTypes.object.isRequired
  }

  renderInterviewStatus(interviewStatus) {
    const cohort = this.props.cohort;
    return <Queue.InterviewStatus key={`${cohort.id}-${interviewStatus.id}`}
                                  interviewStatus={interviewStatus} cohort={cohort} />
  }

  render() {
    const cohort = this.props.cohort;
    return (
      <div>
        {cohort.interviewStatuses.map(this.renderInterviewStatus.bind(this))}
      </div>
    );
  }
}

