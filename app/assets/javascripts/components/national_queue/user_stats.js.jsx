window.NationalQueue = window.NationalQueue || {};
const useState = React.useState;

window.NationalQueue.UserStats = ({user}) => {
  const {assistances, queueTasks, avgRating, avgWait, timeFilter, setTimeFilter, loading} = window.NationalQueue.useQueueStatistics(user);

  const changeTimeRange = (e, time) => {
    e.stopPropagation();
    setTimeFilter(time);
  }

  const icon = () => {
    return <i className="fas fa-chart-line"></i>
  }

  const tasks = () => {
    return (
      <div className="tasks">
        <div className="stat">
          <div className="quantity">
            <h2>{queueTasks.length}</h2>
            <p>Assigned</p>
          </div>
          <i className="fas fa-arrow-right text-primary"></i>
          <div className="quantity">
            <h2>{assistances.length}</h2>
            <p>Assisted</p>
          </div>
        </div>
        <div className="stat">
          <div className="quantity">
            <h2>{avgRating}</h2>
            <p>Avg. Rating</p>
          </div>
        </div>
        <div className="stat">
          <div className="quantity">
            <h2>{avgWait} </h2>
            <p>Avg. Time to Assist</p>
          </div>
        </div>
      </div>
    );
  }

  const timeOptions = () => {
    return (
      <div className="d-flex queue-time-filter">
         <i onClick={(e) => changeTimeRange(e, 'day')} className={"fas fa-calendar-day" +  (timeFilter === 'day' ? ' selected' : '')}></i>
         <i onClick={(e) => changeTimeRange(e, 'week')} className={"fas fa-calendar-week" + (timeFilter === 'week' ? ' selected' : '')}></i>
         <i onClick={(e) => changeTimeRange(e, 'month')} className={"fas fa-calendar-alt" + (timeFilter === 'month' ? ' selected' : '')}></i>
      </div>
    )
  }

  return(
    <NationalQueue.ListGroup icon={icon()} title={user.fullName} header={timeOptions()}>
      <div className="national-queue-stats">
        <div className="group">
          <h5>Tasks</h5>
          <div className="info">
            {loading ? <i className="fas fa-spinner text-primary queue-loader"></i> : tasks()}
          </div>
        </div>
      </div>
    </NationalQueue.ListGroup>
  )
}
