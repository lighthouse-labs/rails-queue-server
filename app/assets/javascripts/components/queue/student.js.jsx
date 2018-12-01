window.Queue || (window.Queue = {});

window.Queue.Student = class Student extends React.Component {
  propTypes: {
    student: PropTypes.object.isRequired
  }

  openModal = () => {
    this.refs.requestModal.open();
  }

  render() {
    const student = this.props.student;

    return(
      <Queue.QueueItem type='Student'>
        <Queue.StudentInfo student={student} when={student.lastAssistedAt} showDetails={true} />

        <div className="actions pull-right">
          <button className="btn btn-sm btn-light btn-main" onClick={this.openModal}>Assistance / Note</button>
        </div>

        <Queue.RequestModal student={student} ref="requestModal" />
      </Queue.QueueItem>
    )
  }

}