window.NationalQueue = window.NationalQueue || {};

window.NationalQueue.CohortInterviewStatuses = ({cohort}) => {

  const renderInterviewStatus = (interviewStatus) => {
    return <NationalQueue.InterviewStatus key={`${cohort.id}-${interviewStatus.id}`}
                                  interviewStatus={interviewStatus} cohort={cohort} />
  }

  return (
    <div>
      {cohort.interviewStatuses.map(renderInterviewStatus)}
    </div>
  )
}
