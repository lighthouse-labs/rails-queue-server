window.TestActivityAttempts || (window.TestActivityAttempts = {});

window.TestActivityAttempts.App = class App extends React.Component {
  static propTypes = {
    programmingTest: PropTypes.shape({
      id: PropTypes.number.isRequired,
      exam_code: PropTypes.string.isRequired
    }).isRequired
  }

  constructor(props) {
    super(props)

    this.state = {
      token: null,
      loading: true,
      error: null
    }
  }

  componentDidMount() {
    const { programmingTest } = this.props

    const url = `/programming_tests/${programmingTest.id}/attempt`

    $.ajax({
      dataType: 'json',
      method: 'GET',
      url
    }).done(resp => {
      this.setState({ token: resp.attempt.token })
    }).always(() => {
      this.setState({ loading: false })
    })
  }

  render() {
    const { loading, token, error } = this.state

    if (loading) {
      return <span>Loading ...</span>
    }

    return (
      <React.Fragment>
        {error && !token && <TestActivityAttempts.ErrorMessage message={error} />}
        {token && !error && <TestActivityAttempts.TokenDisplay token={token} />}
        {token === null && <button
          className="btn btn-primary"
          onClick={this._handleCreateAttempt}
        >
          Click here to start the test
        </button>}
      </React.Fragment>
    )
  }

  _handleCreateAttempt = () => {
    const { programmingTest } = this.props;
    this.setState({ loading: true })

    const url = `/programming_tests/${programmingTest.id}/attempt`;

    $.ajax({
      dataType: 'json',
      method: 'POST',
      url
    }).done((resp, _, xhr) => {
      this.setState({ token: resp.attempt.token, error: null })
    }).fail((xhr, _, error) => {
      this.setState({ error: xhr.responseJSON.error })
    }).always(() => {
      this.setState({ loading: false })
    })
  }
}

window.TestActivityAttempts.TokenDisplay = ({ token }) => (
  <div>
    <div>Use this code to start the test:</div>
    <div className="exam-token">
      <code>{token}</code>
    </div>
  </div>
)

window.TestActivityAttempts.ErrorMessage = ({ message }) => (
  <div className="alert alert-danger">
    {message}
  </div>
)
