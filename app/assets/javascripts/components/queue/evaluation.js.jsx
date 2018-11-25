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

  render() {
    const evaluation = this.props.evaluation;
    const project = evaluation.project
    const student = evaluation.student;
    const evaluator = evaluation.teacher;

    return (
      <li className="evaluation list-group-item clearfix">
        <div className="type evaluation">
          <div className="text">Evaluation</div>
        </div>

        <Queue.StudentInfo  student={student}
                            showDetails={true}
                            when={evaluation.createdAt}
                             />


        { evaluator ? this.renderEvaluator(evaluator, evaluation) : nil }

        <div className="blurb">
          <blockquote>{evaluation.studentNotes}</blockquote>
        </div>
        <div className="actions pull-right">
          <button className="btn btn-sm btn-danger" onClick={this.handleCancelEvaluating} disabled={this.state.disabled}>Cancel</button>
          <a className="btn btn-sm btn-primary" href={`/projects/${project.slug}/evaluations/${evaluation.id}/edit`} disabled={this.state.disabled}>View</a>
        </div>
      </li>
    )
  }
}

