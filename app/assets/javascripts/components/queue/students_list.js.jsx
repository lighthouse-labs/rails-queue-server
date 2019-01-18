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
      <Queue.ListGroup count={this.props.students.length} title="Students">
        {this.renderStudents()}
      </Queue.ListGroup>
    );
  }
}

