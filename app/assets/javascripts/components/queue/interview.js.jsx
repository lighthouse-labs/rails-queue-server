window.Queue || (window.Queue = {});

window.Queue.Interview = class Interview extends React.Component {
  propTypes: {
    interview: PropTypes.object.isRequired
  }

  constructor(props) {
    super(props);
    this.state = { disabled: false };
  }

  // renderInterviewer(interviewer, interview) {
  //   return(
  //     <div className="assister clearfix">
  //       <div className="arrow"><span>&#10551;</span></div>
  //       <img className="avatar" src={interviewer.avatarUrl} />
  //       <div className="info">
  //         <div className="name">{interviewer.firstName} {interviewer.lastName}</div>
  //         <div className="details">

  //         </div>
  //       </div>
  //     </div>
  //   );
  // }

  truncatedDescription(interview) {
    const desc = interview.techInterviewTemplate.description;
    return _.truncate(desc.split('. ').splice(0, 1).join('. '), {length: 105});
  }

  render() {
    const interview = this.props.interview;
    const project = interview.project
    const interviewee = interview.interviewee;
    const interviewer = interview.interviewer;

    return (
      <li className="interview list-group-item clearfix">
        <div className="type">
          <div className="text">Interview</div>
        </div>

        <Queue.StudentInfo  student={interviewee}
                            showDetails={true}
                            when={interview.createdAt}
                             />


        { interviewer ? <Queue.TeacherInfo teacher={interviewer} /> : nil }

        <div className="blurb">
          <blockquote>{this.truncatedDescription(interview)}</blockquote>
        </div>
        <div className="actions pull-right">
          <button className="btn btn-sm btn-light btn-hover-danger" onClick={this.handleCancelEvaluating} disabled={this.state.disabled}>Cancel</button>
          <a className="btn btn-sm btn-secondary btn-main" href={`/tech_interviews/${interview.id}/edit`} disabled={this.state.disabled}>View</a>
        </div>
      </li>
    )
  }
}

