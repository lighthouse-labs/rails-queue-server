window.NationalQueue = window.NationalQueue || {};

window.NationalQueue.StudentInfo = ({student, activity, project, when, showDetails}) => {

  const renderWhen = () => {
    if (when) {
      return <TimeAgo date={when} />;
    } else {
      return <span>Never Helped</span>;
    }
  }

  const renderDetails = () => {
    if (!showDetails) return;

    let cohort = student.cohort;
    let project = project || (activity && activity.project);

    // always have one empty element otherwise it could fail on reduce - KV
    let badges = [null];

    if (cohort && cohort.week)
      badges.push(
        <React.Fragment key="badgegroup">
          <span key="locationbadge" className="badge badge-light">{student.location && student.location.name}</span>
          <a
            key="weekbadge"
            className="badge badge-light"
            href={`/cohorts/${cohort.id}/students`}
          >
            W{cohort.week}
          </a>
        </React.Fragment>
      );
    if (project)
      badges.push(
        <a
          key="projectbadge"
          className="badge badge-light"
          href={`/projects/${project.slug}`}
        >
          {_.truncate(project.name, { length: 13, omission: null })}
        </a>
      );

    return (
      <div className="details">
        {App.ReactUtils.joinElements(badges)}
        <br />
        <span className="time">{renderWhen()}</span>
      </div>
    );
  }

  const pronoun = (student) => {
    return student.pronoun ? (
      <span title="Pronoun" className="pronoun">
        ({student.pronoun})
      </span>
    ) : null;
  }

  return (
    <div className="assistee clearfix">
      <a href={`/teacher/students/${student.id}`} title="Details">
        <img className="avatar" src={student.avatarUrl} />
      </a>
      <div className="info">
        <div className="name">
          &nbsp;
          {student.firstName} {student.lastName} {pronoun(student)}
          <br />
          <NationalQueue.SocialIcons user={student} />
        </div>
        {renderDetails()}
      </div>
    </div>
  )
}
