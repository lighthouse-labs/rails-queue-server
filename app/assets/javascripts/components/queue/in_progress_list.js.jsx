window.Queue || (window.Queue = {});

window.Queue.InProgressList = class InProgressList extends React.Component {
  propTypes: {
    assistances: PropTypes.array.isRequired,
    evaluations: PropTypes.array.isRequired
  }

  renderAssistance(assistance) {
    return <Queue.Assistance key={`assistance-${assistance.id}`} assistance={assistance} />
  }

  renderEvaluation(evaluation) {
    return <Queue.Evaluation key={`evaluation-${evaluation.id}`} evaluation={evaluation} />
  }

  renderAssistances() {
    return this.props.assistances.map(this.renderAssistance.bind(this));
  }

  renderEvaluations() {
    return this.props.evaluations.map(this.renderEvaluation.bind(this));
  }

  render() {
    return (
      <div className="card card-default">
        <div className="card-header clearfix">
          <h5 className="card-title">
            <span className="count">{this.props.assistances.length + this.props.evaluations.length}</span>
            <span className="title">In Progress</span>
          </h5>
        </div>
        <ul className="list-group">
          {this.renderAssistances()}
          {this.renderEvaluations()}
        </ul>
      </div>
    );
  }
}

