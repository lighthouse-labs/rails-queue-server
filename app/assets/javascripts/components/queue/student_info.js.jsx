window.Queue || (window.Queue = {});

window.Queue.StudentInfo = class StudentInfo extends React.Component {
  propTypes: {
    student: PropTypes.object.isRequired,
    activity: PropTypes.object,
    when: PropTypes.string,
    showDetails: PropTypes.bool
  }

  renderDetails() {
    if (!this.props.showDetails) return;

    let when = this.props.when || new Date();
    let student = this.props.student;
    let cohort = student.cohort;
    let activity = this.props.activity;
    let project = activity && activity.project;

    let weekBadge;
    let projectBadge;

    if (cohort && cohort.week) weekBadge = (<a className="badge badge-primary" href={`/cohorts/${cohort.id}/students`}>W{cohort.week}</a>)

    if (project) projectBadge = (<a className="badge badge-info" href={`/projects/${project.slug}`}>{project.name}</a>)

    // ~ {moment(when).fromNow()}
    return (
      <div className="details">
        {weekBadge}
        {projectBadge}
        <br/>
        <span className="time">
          ~ <TimeAgo date={when} />
        </span>
      </div>
    )
  }

  renderActivityDetails(activity) {
    if (!activity) return;

    return (
      <a className="resource-name" href={`/${activity.uuid}`}>{activity.name}</a>
    )
  }

  render() {
    const student = this.props.student;
    const activity = this.props.activity;

    // "https://avatars.githubusercontent.com/u/20713265?v=3"
    return (
      <div className="assistee clearfix">
        <img className="avatar" src={student.avatarUrl} />
        <div className="info">
          <div className="name">
            {student.firstName} {student.lastName}
            <br/>
            {this.renderActivityDetails(activity)}
          </div>
          {this.renderDetails()}
        </div>
      </div>
    );
  }
}

