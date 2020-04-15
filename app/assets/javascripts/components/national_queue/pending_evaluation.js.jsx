window.Queue = window.Queue || {};
const useState = React.useState;

window.Queue.PendingEvaluation = ({evaluation}) => {
  const [disabled, setDisabled] = useState(false);

  const handleStartEvaluating = () => {
    // setDisabled(true);
    // App.queue.startEvaluating(evaluation);
    // ga('send', 'event', 'start-marking', 'click');
  }

  const renderResubmissionLabel = (evaluation) => {
    if (evaluation.resubmission)  {
      return (<span className="badge badge-warning badge-sm float-right">resubmission</span>);
    }
  }


  return (
    <NationalQueue.QueueItem type='Submission' disabled={disabled}>

      <NationalQueue.StudentInfo  student={evaluation.student}
                          project={evaluation.project}
                          showDetails={true}
                          when={evaluation.createdAt} />

      <div className="blurb">
        <a href={evaluation.githubUrl} target="_blank">{evaluation.githubUrl}</a>
        {renderResubmissionLabel(evaluation)}
        <br/>
        {App.ReactUtils.renderQuote(evaluation.studentNotes, 300)}
      </div>

      <div className="actions float-right">
        <a className="btn btn-sm btn-light" href={`/projects/${evaluation.project.slug}/evaluations/${evaluation.id}`}>View</a>
        <button className="btn btn-sm btn-secondary btn-main" disabled={disabled} onClick={handleStartEvaluating}>Start Evaluating</button>
      </div>
    </NationalQueue.QueueItem>
  )
}

