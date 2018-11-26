window.Queue || (window.Queue = {});

window.Queue.InProgressList = class InProgressList extends React.Component {
  propTypes: {
    assistances: PropTypes.array.isRequired,
    evaluations: PropTypes.array.isRequired,
    interviews: PropTypes.array.isRequired
  }

  renderAssistance = (assistance) => {
    return <Queue.Assistance key={`assistance-${assistance.id}`} assistance={assistance} />
  }

  renderEvaluation = (evaluation) => {
    return <Queue.Evaluation key={`evaluation-${evaluation.id}`} evaluation={evaluation} />
  }

  renderInterview = (interview) => {
    return <Queue.Interview key={`interview-${interview.id}`} interview={interview} />
  }

  renderAssistances() {
    return this.props.assistances.map(this.renderAssistance);
  }

  renderInterviews() {
    return this.props.interviews.map(this.renderInterview);
  }

  renderEvaluations() {
    return this.props.evaluations.map(this.renderEvaluation);
  }

  render() {
    return (
      <div className="card card-default">
        <div className="card-header clearfix">
          <h5 className="card-title">
            <span className="count">{this.props.assistances.length + this.props.evaluations.length + this.props.interviews.length}</span>
            <span className="title">In Progress</span>
          </h5>
        </div>
        <ul className="list-group">
          {this.renderAssistances()}
          {this.renderInterviews()}
          {this.renderEvaluations()}
        </ul>
      </div>
    );
  }
}

