window.NationalQueue = window.NationalQueue || {};
const useState = React.useState;

window.NationalQueue.Interview = ({interview}) => {
  const [disabled, setDisabled] = useState(false);

  const truncatedDescription = (interview) => {
    const desc = interview.techInterviewTemplate.description;
    return _.truncate(desc.split('. ').splice(0, 1).join('. '), {length: 105});
  }

  const handleCancelInterviewing = () => {
    setDisabled(true);
    App.queue.cancelInterviewing(interview);
    ga('send', 'event', 'cancel-interviewing', 'click');
  }

  const actionButtons = () => {
    const buttons = [null];
    const interview = interview;
    if (interview.interviewer && window.current_user.id === interview.interviewer.id) {
      buttons.push(<button key="cancel" className="btn btn-sm btn-light btn-hover-danger" onClick={handleCancelInterviewing} disabled={disabled}>Cancel</button>);
      buttons.push(<a key="view" className="btn btn-sm btn-secondary btn-main" href={`/tech_interviews/${interview.id}/edit`} disabled={disabled}>View</a>);
    }
    return buttons;
  }

  const renderActions = () => {
    return(
      <div className="actions float-right">
        { App.ReactUtils.joinElements(actionButtons(), null) }
      </div>
    )
  }

  const interviewee = interview.interviewee;
  const interviewer = interview.interviewer;

  return (
    <NationalQueue.QueueItem type='Interview' disabled={disabled}>

      <NationalQueue.StudentInfo  student={interviewee}
                          showDetails={true}
                          when={interview.createdAt} />

      { interviewer && <NationalQueue.TeacherInfo teacher={interviewer} /> }

      <div className="blurb">
        <blockquote>
          <strong>Week {interview.techInterviewTemplate.week } Interview: </strong>
          {truncatedDescription(interview)}
        </blockquote>
      </div>
      { renderActions() }
    </NationalQueue.QueueItem>
  )
}

