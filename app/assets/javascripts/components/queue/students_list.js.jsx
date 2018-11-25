window.Queue || (window.Queue = {});

window.Queue.StudentsList = class StudentsList extends React.Component {
  propTypes: {
    students: PropTypes.array
  }

  renderStudent(student) {
    return <Queue.Student key={`student-${student.id}`} student={student} />
  }

  renderStudents() {
    return this.props.students.map(this.renderStudent);
  }

  render() {
    return (
      <div className="card card-default">
        <div className="card-header clearfix">
          <h5 className="card-title">
            <span className="count">{this.props.students.length}</span>
            <span className="title">Students</span>
          </h5>
        </div>
        <ul className="list-group">
          {this.renderStudents()}
        </ul>
      </div>
    );
  }
}

