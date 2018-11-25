window.Queue || (window.Queue = {});

window.Queue.PendingAssistanceRequest = class PendingAssistanceRequest extends React.Component {

  propTypes: {
    request: PropTypes.object
  }

  constructor(props) {
    super(props);
    this.state = { disabled: false }
  }

  handleCancelAssistance = () => {
    // TODO: use more js-centric confirm vs browser confirm
    if(confirm("Are you sure you want to cancel this Request?")) {
      this.setState({disabled: true})
      App.queue.cancelAssistanceRequest(this.props.request);
      ga('send', 'event', 'cancel-assistance', 'click');
    }
  }

  handleStartAssisting = () => {
    this.setState({disabled: true})
    App.queue.startAssisting(this.props.request);
    ga('send', 'event', 'start-assistance', 'click');
  }

  render() {
    const request = this.props.request;
    const student = request.requestor;

    return (
      <li className="assistance list-group-item clearfix">
        <div className="type assistance">
          <div className="text">Assistance</div>
        </div>

        <Queue.StudentInfo  student={student}
                            showDetails={true}
                            when={request.startAt}
                            activity={request.activity} />

        <div className="blurb">
          <blockquote>{request.reason}</blockquote>
        </div>
        <div className="actions pull-right">
          <button className="btn btn-sm btn-danger" onClick={this.handleCancelAssistance} disabled={this.state.disabled}>Remove!</button>
          <button className="btn btn-sm btn-primary" onClick={this.handleStartAssisting} disabled={this.state.disabled}>Start Assisting</button>
        </div>
      </li>
    )
  }
}

