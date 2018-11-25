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
    App.queue.stopAssisting(this.props.assistance);
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
      <li className="assistance list-group-item clearfix">
        <div className="type assistance">
          <div className="text">Assistance</div>
        </div>

        <Queue.StudentInfo  student={student}
                            showDetails={true}
                            when={request.startAt}
                             />


        <div className="assister clearfix">
          <div className="arrow"><span>&#10551;</span></div>
          <img className="avatar" src={assistor.avatarUrl} />
          <div className="info">
            <div className="name">{assistor.firstName} {assistor.lastName}</div>
            <div className="details">
              <span className="time"><TimeAgo date={assistance.startAt} /></span>
            </div>
          </div>
        </div>

        <div className="blurb">
          <blockquote>{assistance.blurb}</blockquote>
        </div>
        <div className="actions pull-right">
          <button className="btn btn-sm btn-danger" onClick={this.handleCancelAssisting} disabled={this.state.disabled}>Cancel</button>
          <button className="btn btn-sm btn-primary"onClick={this.handleEndAssisting} disabled={this.state.disabled}>Finished</button>
        </div>

        <Queue.RequestModal assistance={assistance} ref="requestModal" />
      </li>
    )
  }
}

