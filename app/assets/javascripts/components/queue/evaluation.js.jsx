window.Queue || (window.Queue = {});

window.Queue.Evaluation = class Evaluation extends React.Component {
  propTypes: {
    evaluation: PropTypes.object
  }

  constructor(props) {
    super(props);
    this.state = { disabled: false };
  }

  handleCancelEvaluating = () => {
    this.setState({disabled: true});
    App.queue.cancelEvaluating(this.props.evaluation);
    ga('send', 'event', 'cancel-marking', 'click');
  }

  renderEvaluator(evaluator, evaluation) {
    return(
      <div className="assister clearfix">
        <div className="arrow"><span>&#10551;</span></div>
        <img className="avatar" src={evaluator.avatarUrl} />
        <div className="info">
          <div className="name">{evaluator.firstName} {evaluator.lastName}</div>
          <div className="details">
            <span className="time"><TimeAgo date={evaluation.startedAt} /></span>
          </div>
        </div>
      </div>
    );
  }

  renderQuote(quote, length=200) {
    return (<blockquote title={quote}>&ldquo;{_.truncate(quote, {length: length})}&rdquo;</blockquote>)
  }

  render() {
    const evaluation = this.props.evaluation;
    const project = evaluation.project
    const student = evaluation.student;
    const evaluator = evaluation.teacher;

    return (
      <Queue.QueueItem type='Evaluation' disabled={this.state.disabled}>

        <Queue.StudentInfo  student={student}
                            showDetails={true}
                            when={evaluation.createdAt}
                             />


        { evaluator ? this.renderEvaluator(evaluator, evaluation) : nil }

        <div className="blurb">
          {this.renderQuote(evaluation.studentNotes)}
        </div>
        <div className="actions pull-right">
          <button className="btn btn-sm btn-light btn-hover-danger" onClick={this.handleCancelEvaluating} disabled={this.state.disabled}>Cancel</button>
          <a className="btn btn-sm btn-secondary btn-main" href={`/projects/${project.slug}/evaluations/${evaluation.id}/edit`} disabled={this.state.disabled}>View</a>
        </div>
      </Queue.QueueItem>
    )
  }
}

