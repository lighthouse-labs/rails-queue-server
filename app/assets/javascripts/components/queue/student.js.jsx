window.Queue || (window.Queue = {});

window.Queue.Student = class Student extends React.Component {
  propTypes: {
    student: PropTypes.object.isRequired
  }

  openModal = () => {
    this.refs.requestModal.open()
  }

  render() {
    const student = this.props.student;

    return(
      <li className="list-group-item student clearfix">
        <div className="type student">
          <div className="text">Student</div>
        </div>
        <Queue.StudentInfo student={student} when={student.lastAssistedAt} showDetails={true} />

        <div className="actions pull-right">
          <button className="btn btn-sm btn-primary" onClick={this.openModal}>Assisted</button>
        </div>

        <Queue.RequestModal student={student} ref="requestModal" />
      </li>
    )
  }

}