window.NationalQueue = window.NationalQueue || {};

window.NationalQueue.PendingEvaluationsList = ({tasks}) => {
  const renderEvaluation = (evaluation) => {
    return <NationalQueue.PendingEvaluation key={`eval-${evaluation.id}`} evaluation={evaluation.taskObject} />
  }

  const renderEvaluations = () => {
    return tasks.map(renderEvaluation);
  }

  return (
    <NationalQueue.ListGroup count={tasks.length} title="Pending Evaluations">
      {renderEvaluations()}
    </NationalQueue.ListGroup>
  );
}

