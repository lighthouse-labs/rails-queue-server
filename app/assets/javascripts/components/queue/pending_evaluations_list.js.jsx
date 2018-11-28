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
      <Queue.ListGroup count={this.props.evaluations.length} title="Pending Evaluations">
        {this.renderEvaluations()}
      </Queue.ListGroup>
    );
  }
}

