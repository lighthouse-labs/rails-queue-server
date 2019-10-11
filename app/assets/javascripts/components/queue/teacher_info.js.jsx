window.Queue || (window.Queue = {});

window.Queue.TeacherInfo = class TeacherInfo extends React.Component {
  propTypes: {
    teacher: PropTypes.object.isRequired,
    when: PropTypes.string,
  }

  renderWhen() {
    if (this.props.when) {
      return <span className="time"><TimeAgo date={this.props.when} /></span>
    }
  }

  pronoun(teacher) {
    if (teacher.pronoun) {
      return <span title="Pronoun" className="pronoun">({teacher.pronoun})</span>
    }
  }

  highlightMe(teacher) {
    if (teacher.id === window.current_user.id) {
      return <span className="bg-light text-danger">(You)</span>
    }
  }

  render() {
    const teacher = this.props.teacher;

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
            {this.highlightMe(teacher)}
            <br/>
            {this.pronoun(teacher)}
          </div>
          <div className="details">
            { this.renderWhen() }
          </div>
        </div>
      </div>
    );
  }
}

