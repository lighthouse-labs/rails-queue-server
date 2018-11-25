window.Queue || (window.Queue = {});

window.Queue.PendingEvaluationsList = class PendingEvaluationsList extends React.Component {
  propTypes: {
    eveluations: PropTypes.array
  }

  renderEvaluation(evaluation) {
    return <Queue.PendingEvaluation key={`eval-${evaluation.id}`} evaluation={evaluation} />
  }

  renderEvaluations() {
    return this.props.evaluations.map(this.renderEvaluation);
  }

  render() {
    return (
      <div className="card card-default">
        <div className="card-header clearfix">
          <h5 className="card-title">
            <span className="count">{this.props.evaluations.length}</span>
            <span className="title">Pending Evaluations</span>
          </h5>
        </div>
        <ul className="list-group">
          {this.renderEvaluations()}
        </ul>
      </div>
    );
  }
}

