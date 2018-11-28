window.Queue || (window.Queue = {});

window.Queue.PendingEvaluation = class PendingEvaluation extends React.Component {
  propTypes: {
    evaluation: PropTypes.object.isRequired
  }

  constructor(props) {
    super(props);
    this.state = { disabled: false };
  }

  handleStartEvaluating = () => {
    this.setState({disabled: true});
    App.queue.startEvaluating(this.props.evaluation);
    ga('send', 'event', 'start-marking', 'click');
  }

  render() {
    const evaluation = this.props.evaluation;
    const student = evaluation.student;
    const disabled = this.state.disabled;

    return (
      <li className="submission list-group-item clearfix">
        <div className="type">
          <div className="text">Submission</div>
        </div>

        <Queue.StudentInfo  student={student}
                            project={evaluation.project}
                            showDetails={true}
                            when={evaluation.createdAt} />

        <div className="blurb">
          <blockquote>{evaluation.studentNotes}</blockquote>
        </div>

        <div className="actions pull-right">
          <button className="btn btn-sm btn-light btn-hover-danger" disabled={disabled}>Remove</button>
          <button className="btn btn-sm btn-main" disabled={disabled} onClick={this.handleStartEvaluating}>Start Evaluating</button>
        </div>
      </li>
    )
  }
}

