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

  renderResubmissionLabel(evaluation) {
    if (evaluation.resubmission)  {
      return (<span className="badge badge-warning badge-sm float-right">resubmission</span>);
    }
  }

  render() {
    const evaluation = this.props.evaluation;
    const student = evaluation.student;
    const disabled = this.state.disabled;

    return (
      <Queue.QueueItem type='Submission' disabled={this.state.disabled}>

        <Queue.StudentInfo  student={student}
                            project={evaluation.project}
                            showDetails={true}
                            when={evaluation.createdAt} />

        <div className="blurb">
          <a href={evaluation.githubUrl} target="_blank">{evaluation.githubUrl}</a>
          {this.renderResubmissionLabel(evaluation)}
          <br/>
          {App.ReactUtils.renderQuote(evaluation.studentNotes, 300)}
        </div>

        <div className="actions float-right">
          <a className="btn btn-sm btn-light" href={`/projects/${evaluation.project.slug}/evaluations/${evaluation.id}`}>View</a>
          <button className="btn btn-sm btn-secondary btn-main" disabled={disabled} onClick={this.handleStartEvaluating}>Start Evaluating</button>
        </div>
      </Queue.QueueItem>
    )
  }
}

