window.Queue || (window.Queue = {});

window.Queue.PendingAssistanceRequest = class PendingAssistanceRequest extends React.Component {
  propTypes: {
    request: PropTypes.object
  }

  constructor(props) {
    super(props);
    this.state = { disabled: false };
  }

  handleCancelAssistance = () => {
    // TODO: use more js-centric confirm vs browser confirm
    if(confirm("Are you sure you want to cancel this Request?")) {
      this.setState({disabled: true});
      App.queue.cancelAssistanceRequest(this.props.request);
      ga('send', 'event', 'cancel-assistance', 'click');
    }
  }

  handleStartAssisting = () => {
    this.setState({disabled: true});
    App.queue.startAssisting(this.props.request);
    ga('send', 'event', 'start-assistance', 'click');
  }

  actionButtons() {
    const buttons = [null];
    buttons.push(<button key="remove" className="btn btn-sm btn-light btn-hover-danger" onClick={this.handleCancelAssistance} disabled={this.state.disabled}>Remove</button>)
    buttons.push(<button key="start" className="btn btn-sm btn-secondary btn-main" onClick={this.handleStartAssisting} disabled={this.state.disabled}>Start Assisting</button>)
    return buttons;
  }

  renderActions() {
    return(
      <div className="actions pull-right">
        { App.ReactUtils.joinElements(this.actionButtons(), null) }
      </div>
    );
  }

  renderActivityDetails(activity) {
    if (!activity) return;
    return (
      <a className="resource-name" href={`/${activity.uuid}`}>{activity.name}</a>
    );
  }

  render() {
    const request = this.props.request;
    const student = request.requestor;

    return (
      <Queue.QueueItem type='Request' disabled={this.state.disabled}>
        <Queue.StudentInfo  student={student}
                            showDetails={true}
                            when={request.startAt}
                            activity={request.activity} />

        <div className="blurb">
          {this.renderActivityDetails(request.activity)}
          {App.ReactUtils.renderQuote(request.reason)}
        </div>
        {this.renderActions()}
      </Queue.QueueItem>
    )
  }
}

