window.Queue || (window.Queue = {});

window.Queue.Interview = class Interview extends React.Component {
  propTypes: {
    interview: PropTypes.object.isRequired
  }

  constructor(props) {
    super(props);
    this.state = { disabled: false };
  }

  truncatedDescription(interview) {
    const desc = interview.techInterviewTemplate.description;
    return _.truncate(desc.split('. ').splice(0, 1).join('. '), {length: 105});
  }

  handleCancelInterviewing = () => {
    this.setState({disabled: true});
    App.queue.cancelInterviewing(this.props.interview);
    ga('send', 'event', 'cancel-interviewing', 'click');
  }

  actionButtons() {
    const buttons = [null];
    const interview = this.props.interview;
    if (interview.interviewer && window.current_user.id === interview.interviewer.id) {
      buttons.push(<button key="cancel" className="btn btn-sm btn-light btn-hover-danger" onClick={this.handleCancelInterviewing} disabled={this.state.disabled}>Cancel</button>);
      buttons.push(<a key="view" className="btn btn-sm btn-secondary btn-main" href={`/tech_interviews/${interview.id}/edit`} disabled={this.state.disabled}>View</a>);
    }
    return buttons;
  }

  renderActions() {
    return(
      <div className="actions pull-right">
        { App.ReactUtils.joinElements(this.actionButtons(), null) }
      </div>
    )
  }

  render() {
    const interview   = this.props.interview;
    const project     = interview.project
    const interviewee = interview.interviewee;
    const interviewer = interview.interviewer;

    return (
      <Queue.QueueItem type='Interview' disabled={this.state.disabled}>

        <Queue.StudentInfo  student={interviewee}
                            showDetails={true}
                            when={interview.createdAt} />

        { interviewer ? <Queue.TeacherInfo teacher={interviewer} /> : nil }

        <div className="blurb">
          <blockquote>
            <strong>Week {interview.techInterviewTemplate.week } Interview: </strong>
            {this.truncatedDescription(interview)}
          </blockquote>
        </div>
        { this.renderActions() }
      </Queue.QueueItem>
    )
  }
}

