window.Queue || (window.Queue = {});

window.Queue.InterviewStatus = class InterviewStatus extends React.Component {
  propTypes: {
    cohort: PropTypes.object.isRequired,
    interviewStatus: PropTypes.object.isRequired
  }

  render() {
    const cohort = this.props.cohort;
    const interviewStatus = this.props.interviewStatus;
    const totalCount = cohort.activeStudentCount;
    const completedCount = interviewStatus.completedStudentIds.length;
    const completedPercent = totalCount === 0 ? 0 : Math.min(100, Math.round((completedCount / totalCount) * 100));
    const completed = completedPercent >= 100;

    // No need to render completed weeks unless the interview status is for THIS week
    if (completed && cohort.week !== interviewStatus.week) return null;

    const overdue = Number(cohort.week) > Number(interviewStatus.week);

    let barClass = '';
    if (completed) {
      barClass = 'bg-success';
    } else if (overdue) {
      barClass = 'bg-danger';
    } else if (completedPercent < 40) {
      barClass = 'bg-warning';
    } else if (completedPercent < 75) {
      barClass = 'bg-info';
    }

    return (
      <Queue.QueueItem type="Interview Status" label={`Week ${interviewStatus.week}`}>
        <dl className="row mb-0">
          <dt className="col-sm-4">
            <a href={`/tech_interview_templates/${interviewStatus.id}?cohort=${cohort.id}`}>{cohort.name}</a>
          </dt>
          <dd className="col-sm-8">
            <div className="progress" style={ { height: '30px' }}>
              <div className={`progress-bar ${barClass}`} role="progressbar" style={ {width: `${completedPercent}%` } } aria-valuenow={completedPercent} aria-valuemin="0" aria-valuemax="100">
              </div>
              <div className="progress-label badge badge-secondary">
                {completedCount} / {totalCount}
              </div>
            </div>
          </dd>
        </dl>
      </Queue.QueueItem>
    );
  }
}

