window.Queue || (window.Queue = {});

window.Queue.InterviewStatusList = class InterviewStatusList extends React.Component {
  propTypes: {
    cohorts: PropTypes.array.isRequired,
    students: PropTypes.array.isRequired
  }

  renderInterviewStatus(cohort) {
    return <Queue.CohortInterviewStatuses key={cohort.id} cohort={cohort} />
  }

  renderInterviewStatuses() {
    return this.props.cohorts.map(this.renderInterviewStatus);
  }

  render() {
    const cohorts = this.props.cohorts;

    return (
      <Queue.ListGroup count={cohorts.length} title="Tech Interview Status">
        { this.renderInterviewStatuses() }
      </Queue.ListGroup>
    );
  }
}

