window.Queue || (window.Queue = {});

window.Queue.StudentInfo = class StudentInfo extends React.Component {
  propTypes: {
    student: PropTypes.object.isRequired,
    activity: PropTypes.object,
    project: PropTypes.object,
    when: PropTypes.string,
    showDetails: PropTypes.bool
  }

  renderWhen() {
    const when = this.props.when;
    if (when) {
      return(<TimeAgo date={when} />)
    } else {
      return(<span>Never Helped</span>)
    }
  }

  renderTogether(elements, seperator=' ') {
    return elements.reduce((prev, curr) => [prev, seperator, curr])
  }

  renderDetails() {
    if (!this.props.showDetails) return;

    let when = this.props.when;
    let student = this.props.student;
    let cohort = student.cohort;
    let activity = this.props.activity;
    let project = this.props.project || (activity && activity.project);

    let badges = [null]

    if (cohort && cohort.week) badges.push(<a key="weekbadge" className="badge badge-light" href={`/cohorts/${cohort.id}/students`}>W{cohort.week}</a>)
    if (project) badges.push(<a key="projectbadge" className="badge badge-light" href={`/projects/${project.slug}`}>{project.name}</a>)

    return (
      <div className="details">
        { this.renderTogether(badges) }
        <br/>
        <span className="time">
          {this.renderWhen()}
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

  pronoun(student) {
    return (
      student.pronoun ? <p title="Pronoun" className="pronoun">({student.pronoun})</p> : null
    )
  }

  render() {
    const student = this.props.student;
    const activity = this.props.activity;

    return (
      <div className="assistee clearfix">
        <a href={`/teacher/students/${student.id}`} title='Details'>
          <img className="avatar" src={student.avatarUrl} />
        </a>
        <div className="info">
          <div className="name">
            {student.firstName} {student.lastName} {this.pronoun(student)}
          </div>
          {this.renderDetails()}
        </div>
      </div>
    );
  }
}

