window.NationalQueue = window.NationalQueue || {};

window.NationalQueue.PendingInterview = ({interview}) => {
  const student = interview.student;

  return (
    <NationalQueue.QueueItem type='Interview' >

      <NationalQueue.StudentInfo  student={student}
                          showDetails={true} />

      <div className="actions float-right">
        <button className="btn btn-sm btn-danger">Remove</button>
        <button className="btn btn-sm btn-primary">Start Interviewing</button>
      </div>
    </NationalQueue.QueueItem>
  )
}

