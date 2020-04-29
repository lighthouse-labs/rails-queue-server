window.NationalQueue = window.NationalQueue || {};
const useState = React.useState;
const useContext = React.useContext;

window.NationalQueue.Evaluation = ({evaluation}) => {
  const [disabled, setDisabled] = useState(false);
  const queueContext =  window.NationalQueue.QueueContext;
  const queueSocket = useContext(queueContext);

  const handleCancelEvaluating = () => {
    setDisabled(true);
    queueSocket.cancelEvaluating(evaluation)
  }

  const renderEvaluator = (evaluator, evaluation) => {
    return (
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
    )
  }

  const actionButtons = (evaluation) => {
    const project = evaluation.project;

    const buttons = [null];
    if (window.current_user.id === evaluation.teacher.id) {
      buttons.push(<button key="cancel" className="btn btn-sm btn-light btn-hover-danger" onClick={handleCancelEvaluating} disabled={disabled}>Cancel</button>);
      buttons.push(<a key="view" className="btn btn-sm btn-secondary btn-main" href={`/projects/${project.slug}/evaluations/${evaluation.id}/edit`} disabled={disabled}>View</a>);
    }
    return buttons;
  }

  const renderActions = () => {
    return (
      <div className="actions float-right">
        { App.ReactUtils.joinElements(actionButtons(evaluation), null) }
      </div>
    )
  }

  const project = evaluation.project;
  const student = evaluation.student;
  const evaluator = evaluation.teacher;

  return (
    <NationalQueue.QueueItem type='Evaluation' disabled={disabled}>
      <NationalQueue.StudentInfo  student={student}
                          showDetails={true}
                          project={project}
                          when={evaluation.createdAt} />

      { evaluator && renderEvaluator(evaluator, evaluation) }

      <div className="blurb">
        {App.ReactUtils.renderQuote(evaluation.studentNotes)}
      </div>
      {renderActions()}
    </NationalQueue.QueueItem>
  )
}
