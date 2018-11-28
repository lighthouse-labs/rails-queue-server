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

    let badges = []

    if (cohort && cohort.week) badges.push(<a key="weekbadge" className="badge badge-secondary" href={`/cohorts/${cohort.id}/students`}>W{cohort.week}</a>)
    if (project) badges.push(<a key="projectbadge" className="badge badge-info" href={`/projects/${project.slug}`}>{project.name}</a>)

    // console.log('reduce: ', this.renderTogether(badges));
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

