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
      loading: true
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
    const { loading, token } = this.state

    return (
      <React.Fragment>
        {loading && <span>Loading ...</span>}
        {!loading && token && <span>{token}</span>}
        {!loading && token === null && <button
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
      this.setState({ token: resp.attempt.token })
    }).fail((xhr, _, error) => {
      console.log('Got an error', error, xhr.status)
    }).always(() => {
      this.setState({ loading: false })
    })
  }
}

