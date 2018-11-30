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

  renderDetails() {
    if (!this.props.showDetails) return;

    let when = this.props.when;
    let student = this.props.student;
    let cohort = student.cohort;
    let activity = this.props.activity;
    let project = this.props.project || (activity && activity.project);

    // always have one empty element otherwise it could fail on reduce - KV
    let badges = [null]

    if (cohort && cohort.week) badges.push(<a key="weekbadge" className="badge badge-light" href={`/cohorts/${cohort.id}/students`}>W{cohort.week}</a>)
    if (project) badges.push(<a key="projectbadge" className="badge badge-light" href={`/projects/${project.slug}`}>{project.name}</a>)

    return (
      <div className="details">
        { App.ReactUtils.joinElements(badges) }
        <br/>
        <span className="time">
          {this.renderWhen()}
        </span>
      </div>
    )
  }

  pronoun(student) {
    return (
      student.pronoun ? <span title="Pronoun" className="pronoun">({student.pronoun})</span> : null
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

