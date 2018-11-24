window.Queue || (window.Queue = {});

window.Queue.PendingInterview = class PendingInterview extends React.Component {
  propTypes: {
    interview: PropTypes.object.isRequired
  }

  render() {
    const interview = this.props.interview;
    const student = interview.student;

    return (
      <li className="interview list-group-item clearfix">
        <div className="type interview">
          <div className="text">Interview</div>
        </div>

        <Queue.StudentInfo  student={student}
                            showDetails={true} />

        <div className="actions pull-right">
          <button className="btn btn-sm btn-danger">Remove</button>
          <button className="btn btn-sm btn-primary">Start Interviewing</button>
        </div>
      </li>
    )
  }
}

