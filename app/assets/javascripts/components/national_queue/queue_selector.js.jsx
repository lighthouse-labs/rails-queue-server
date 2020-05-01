window.NationalQueue = window.NationalQueue || {};

window.NationalQueue.QueueSelector = ({teachers, userQueue, setUserQueue}) => {

  const toggleUserQueue = (value) => {
    setUserQueue(userQueue !== value ? value : 'admin')
  }

  const selected = (value) => {
    return userQueue && (value === userQueue || userQueue.id === value.id) ? 'selected ' : '';
  }

  const teacherOptions = () => {
    return teachers.map(teacher => {
      return (
        <img 
          key={teacher.id}
          onClick={e => toggleUserQueue(teacher)}
          src={teacher.avatarUrl}
          className={selected(teacher) + (teacher.busy ? " option busy" : ' option')}
          data-toggle='tooltip' 
          data-placement='bottom' 
          title={teacher.fullName}
          data-original-title={`Toggle Admin Queue`}
          // ref={(ref) => $(ref).tooltip()}
        />
      );
    });
  }

  return(
    <div className={`card card-default queue-selector open mb-3`}>
      <div className="card-header-back"></div>
      <div className="card-header-border"></div>
      <div className="card-header">
        <h5 className="card-title">
          <span className="count">{teachers.length}</span>
          <span className="title">Mentors</span>
        </h5>
        <div className="options">
          <div className={selected('admin') + "option all bg-primary"} onClick={e => setUserQueue('admin')}>
            <i className="fas fa-globe-americas"></i>
          </div>
          <div className="mentors">
            {teacherOptions()}
          </div>
        </div>
      </div>
    </div>
  )
}
