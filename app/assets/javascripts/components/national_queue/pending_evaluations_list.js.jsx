window.NationalQueue = window.NationalQueue || {};
const useEffect = React.useEffect;
const useState = React.useState;

window.NationalQueue.PendingEvaluationsList = ({user}) => {
  const [evaluations, setEvaluations] = useState([]);

  useEffect(() => {
    const url = `/queue_tasks/evaluations`
    $.ajax({
      dataType: 'json',
      method: 'GET',
      url
    }).done(resp => {
      setEvaluations(resp.evaluations);
    }).always(() => {
      // setLoading(false);
    })
  }, []);

  const renderEvaluation = (evaluation) => {
    return <NationalQueue.PendingEvaluation key={`eval-${evaluation.id}`} evaluation={evaluation} />
  }

  const renderEvaluations = () => {
    return evaluations.map(renderEvaluation);
  }

  return (
    <NationalQueue.ListGroup count={evaluations.length} title="Pending Evaluations">
      {renderEvaluations()}
    </NationalQueue.ListGroup>
  );
}

