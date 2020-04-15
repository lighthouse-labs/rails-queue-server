window.NationalQueue = window.NationalQueue || {};

window.NationalQueue.InterviewStatus = ({interviewStatus, cohort}) => {

  const completedPercent = (totalCount, completedCount) => {
    return totalCount === 0 ? 0 : Math.min(100, Math.round((completedCount / totalCount) * 100));
  }
  
  const barClass = (percent) => {
    let barClass = '';
    if (completed) {
      barClass = 'bg-success';
    } else if (overdue) {
      barClass = 'bg-danger';
    } else if (percent < 40) {
      barClass = 'bg-warning';
    } else if (percent < 75) {
      barClass = 'bg-info';
    }
    return barClass;
  }
  
  const totalCount = cohort.activeStudentCount;
  const completedCount = interviewStatus.completedStudentIds.length;
  const percent = completedPercent(totalCount, completedCount);
  const completed = percent >= 100;
  const overdue = Number(cohort.week) > Number(interviewStatus.week);
  
  return (
    // No need to render completed weeks unless the interview status is for THIS week
    (completed && cohort.week !== interviewStatus.week) ||
    <NationalQueue.QueueItem type="Interview Status" label={`Week ${interviewStatus.week}`}>
      <dl className="row mb-0">
        <dt className="col-sm-4">
          <a href={`/tech_interview_templates/${interviewStatus.id}?cohort=${cohort.id}`}>{cohort.name}</a>
        </dt>
        <dd className="col-sm-8">
          <div className="progress" style={ { height: '30px' }}>
            <div className={`progress-bar ${barClass(percent)}`} role="progressbar" style={ {width: `${percent}%` } } aria-valuenow={percent} aria-valuemin="0" aria-valuemax="100">
            </div>
            <div className="progress-label badge badge-secondary">
              {completedCount} / {totalCount}
            </div>
          </div>
        </dd>
      </dl>
    </NationalQueue.QueueItem>
  );
}

