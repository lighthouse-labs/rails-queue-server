window.NationalQueue = window.NationalQueue || {};

window.NationalQueue.TeacherInfo = ({teacher, when}) => {

  const renderWhen = () => {
    if (when) {
      return <span className="time"><TimeAgo date={when} /></span>
    }
  }

  const pronoun = (teacher) => {
    if (teacher.pronoun) {
      return <span title="Pronoun" className="pronoun">({teacher.pronoun})</span>
    }
  }

  const highlightMe = (teacher) => {
    if (teacher.id === window.current_user.id) {
      return <span className="bg-light text-danger">(You)</span>
    }
  }

  return (
    <div className="assister clearfix">
      <div className="arrow"><span>&#10551;</span></div>
      <a href={`/teachers/${teacher.id}`} title="Teacher Details">
        <img className="avatar" src={teacher.avatarUrl} />
      </a>
      <div className="info">
        <div className="name">
          {teacher.firstName} {teacher.lastName}
          &nbsp;
          {highlightMe(teacher)}
          <br/>
          {pronoun(teacher)}
        </div>
        <div className="details">
          { renderWhen() }
        </div>
      </div>
    </div>
  );
}
