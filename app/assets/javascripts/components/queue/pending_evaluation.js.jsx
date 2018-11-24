window.Queue || (window.Queue = {});

window.Queue.PendingEvaluation = class PendingEvaluation extends React.Component {
  propTypes: {
    evaluation: PropTypes.object.isRequired
  }

  render() {
    const evaluation = this.props.evaluation;
    const student = evaluation.student;

    return (
      <li className="evaluation list-group-item clearfix">
        <div className="type evaluation">
          <div className="text">Evaluation</div>
        </div>

        <Queue.StudentInfo  student={student}
                            showDetails={true}
                            when={evaluation.startAt} />

        <div className="actions pull-right">
          <button className="btn btn-sm btn-danger">Remove</button>
          <button className="btn btn-sm btn-primary">Start Evaluating</button>
        </div>
      </li>
    )
  }
}

