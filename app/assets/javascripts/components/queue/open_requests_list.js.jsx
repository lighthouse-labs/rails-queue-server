window.Queue || (window.Queue = {});

window.Queue.OpenRequestsList = class OpenRequestsList extends React.Component {
  propTypes: {
    requests: PropTypes.array
  }

  renderRequest(request) {
    return <Queue.PendingAssistanceRequest key={`request-${request.id}`} request={request} />
  }

  renderRequests() {
    return this.props.requests.map(this.renderRequest);
  }

  render() {
    return (
      <Queue.ListGroup count={this.props.requests.length} title="Open Requests">
        {this.renderRequests()}
      </Queue.ListGroup>
    );
  }
}
