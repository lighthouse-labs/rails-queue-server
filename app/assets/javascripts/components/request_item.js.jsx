var RequestItem = React.createClass({

  renderStudentLocation: function() {
    var student = this.props.student;

    if(this.props.location.id != student.location.id)
      return (
        <small>
          - {student.location.name}
          { student.remote ? <span className="badge badge-info">Remote</span> : null }
        </small>
      )
  },

  studentPronoun: function(student) {
    return (
      student.pronoun ? <p className="student-pronoun">({student.pronoun})</p> : null
    )
  },

  render: function() {
    var student = this.props.student;
    return(
      <li>
        <div className="student-avatar">
          <img src={student.avatar_url} />
        </div>

        <div className="student-description">
          <h4 className="student-heading">
            <a href={`/teacher/students/${student.id}`}> {student.first_name} {student.last_name} </a>
            { this.renderStudentLocation() }
          </h4>
          { this.studentPronoun(student) }
          <p className="student-cohort">
            <a href={"cohorts/" + student.cohort.id + "/students"} className="cohort-name">
              {student.cohort.name}
            </a>
          </p>

          { this.props.children }
        </div>
      </li>
    )
  }

})
