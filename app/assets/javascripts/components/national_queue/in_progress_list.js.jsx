window.NationalQueue = window.NationalQueue || {};

window.NationalQueue.InProgressList = ({tasks}) => {
  const renderAssistance = (assistance) => {
    return <NationalQueue.Assistance key={`assistance-${assistance.id}`} assistance={assistance} />
  }

  const renderEvaluation = (evaluation) => {
    return <NationalQueue.Evaluation key={`evaluation-${evaluation.id}`} evaluation={evaluation} />
  }

  const renderInterview = (interview) => {
    return <NationalQueue.Interview key={`interview-${interview.id}`} interview={interview} />
  }

  const renderItem = (item) => {
    if (item.type === 'Assistance') {
      return renderAssistance(item)
    } else if (item.type === 'ProjectEvaluation') {
      return renderEvaluation(item)
    } else if (item.type === 'TechInterview') {
      return renderInterview(item)
    }
  }

  const renderTasks = (tasks) => {
    return tasks.map(renderItem);
  }

  return (
    <NationalQueue.ListGroup count={tasks.length} title="In Progress">
      {renderTasks(tasks)}
    </NationalQueue.ListGroup>
  );
}

