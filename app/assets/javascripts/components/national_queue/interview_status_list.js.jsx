window.NationalQueue = window.NationalQueue || {};
const useEffect = React.useEffect;
const useState = React.useState;

window.NationalQueue.InterviewStatusList = ({user}) => {
  const [cohorts, setCohorts] = useState([]);

  useEffect(()=>{
    const url = `/queue_tasks/cohorts`
    $.ajax({
      dataType: 'json',
      method: 'GET',
      url
    }).done(resp => {
      console.log(resp.cohorts);
      setCohorts(resp.cohorts);
    }).always(() => {
      // setLoading(false);
    })
  }, []);

  const renderInterviewStatus = (cohort) => {
    return <NationalQueue.CohortInterviewStatuses key={cohort.id} cohort={cohort} />
  }

  const renderInterviewStatuses = () => {
    return cohorts.map(renderInterviewStatus);
  }

  return (
    <NationalQueue.ListGroup count={cohorts.length} title="Tech Interview Status">
      { renderInterviewStatuses() }
    </NationalQueue.ListGroup>
  );
}

