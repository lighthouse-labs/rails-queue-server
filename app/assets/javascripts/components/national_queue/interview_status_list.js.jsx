window.NationalQueue = window.NationalQueue || {};
const useEffect = React.useEffect;
const useState = React.useState;

window.NationalQueue.InterviewStatusList = ({updates}) => {
  const [cohorts, setCohorts] = useState([]);
  const {cohortsWithUpdates} = window.NationalQueue.QueueSelectors;

  useEffect(()=>{
    const url = `/queue_tasks/cohorts`
    $.ajax({
      dataType: 'json',
      method: 'GET',
      url
    }).done(resp => {
      setCohorts(resp.cohorts);
    }).always(() => {
      // setLoading(false);
    })
  }, []);

  const renderInterviewStatus = (cohort) => {
    return <NationalQueue.CohortInterviewStatuses key={cohort.id} cohort={cohort} />
  }

  const renderInterviewStatuses = () => {
    const updatedCohorts = cohortsWithUpdates(cohorts, updates);
    return updatedCohorts.map(renderInterviewStatus);
  }

  return (
    <NationalQueue.ListGroup icon={cohorts.length} title="Tech Interview Status">
      { renderInterviewStatuses() }
    </NationalQueue.ListGroup>
  )
}
