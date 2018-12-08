window.Queue || (window.Queue = {});

window.Queue.PendingInterview = class PendingInterview extends React.Component {
  propTypes: {
    interview: PropTypes.object.isRequired
  }

  render() {
    const interview = this.props.interview;
    const student = interview.student;

    return (
      <Queue.QueueItem type='Interview' disabled={this.state.disabled}>

        <Queue.StudentInfo  student={student}
                            showDetails={true} />

        <div className="actions pull-right">
          <button className="btn btn-sm btn-danger">Remove</button>
          <button className="btn btn-sm btn-primary">Start Interviewing</button>
        </div>
      </Queue.QueueItem>
    )
  }
}

