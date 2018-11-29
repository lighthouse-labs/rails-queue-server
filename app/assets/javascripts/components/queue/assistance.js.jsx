window.Queue || (window.Queue = {});

window.Queue.Assistance = class Assistance extends React.Component {
  propTypes: {
    assistance: PropTypes.object
  }

  constructor(props) {
    super(props);
    this.state = { disabled: false };
  }

  handleCancelAssisting = () => {
    this.setState({disabled: true});
    App.queue.cancelAssisting(this.props.assistance);
    ga('send', 'event', 'cancel-assistance', 'click');
  }

  handleEndAssisting = () => {
    this.openModal();
  }

  openModal() {
    this.refs.requestModal.open()
  }

  render() {
    const assistance = this.props.assistance;
    const request = assistance.assistanceRequest;
    const student = assistance.assistee;
    const assistor = assistance.assistor;

    return (
      <Queue.QueueItem type='Assistance' disabled={this.state.disabled}>

        <Queue.StudentInfo  student={student}
                            showDetails={true}
                            when={request.startAt}
                             />

        <Queue.TeacherInfo teacher={assistor} when={assistance.startAt} />

        <div className="blurb">
          <blockquote>{assistance.blurb}</blockquote>
        </div>
        <div className="actions pull-right">
          <button className="btn btn-sm btn-light btn-hover-danger" onClick={this.handleCancelAssisting} disabled={this.state.disabled}>Cancel</button>
          <button className="btn btn-sm btn-secondary btn-main"onClick={this.handleEndAssisting} disabled={this.state.disabled}>Finished</button>
        </div>

        <Queue.RequestModal assistance={assistance} ref="requestModal" />
      </Queue.QueueItem>
    )
  }
}

