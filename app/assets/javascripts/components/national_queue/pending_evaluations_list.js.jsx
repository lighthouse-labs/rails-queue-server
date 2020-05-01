window.NationalQueue = window.NationalQueue || {};

window.NationalQueue.PendingEvaluationsList = ({tasks, open, setOpen}) => {
  const renderEvaluation = (evaluation) => {
    return <NationalQueue.PendingEvaluation key={`eval-${evaluation.id}`} evaluation={evaluation.taskObject} />
  }

  const renderEvaluations = () => {
    return tasks.map(renderEvaluation);
  }
  
  const toggleOpen = () => {
    return open === 'evaluations' ? setOpen(false) : setOpen('evaluations')
  }

  return (
    <NationalQueue.ListGroup open={open === 'evaluations'} toggleOpen={toggleOpen} count={tasks.length} title="Pending Evaluations">
      {renderEvaluations()}
    </NationalQueue.ListGroup>
  )
}
