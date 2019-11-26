window.ProgrammingTests || (window.ProgrammingTests = {})

window.ProgrammingTests.SubmissionsApp = class SubmissionsApp extends React.Component {
  static propTypes = {
    enrollmentId: PropTypes.string.isRequired,
    programmingTests: PropTypes.arrayOf(PropTypes.object).isRequired,
    pollTimeout: PropTypes.number
  }

  static defaultProps = {
    pollTimeout: 7
  }

  constructor(props) {
    super(props)

    this.state = {
      selectedTest: props && props.programmingTests && props.programmingTests[0] && props.programmingTests[0].code || null,
      submissionData: [],
      fetching: false
    }
  }

  componentDidMount() {
    this._fetchData()
  }

  componentDidUpdate(prevProps, prevState) {
    if (this.state.selectedTest !== prevState.selectedTest) {
      this.setState({ submissionData: [] })
      this._cancelPoller()
      this._fetchData()
    }
  }

  componentWillUnmount() {
    this._cancelPoller()
  }

  render() {
    const { programmingTests } = this.props
    const { selectedTest, submissionData } = this.state

    return (
      <div>
        <ProgrammingTests.TabList programmingTests={programmingTests} selectedTab={selectedTest} onTabSelected={(test) => this.setState({ selectedTest: test })} />

        <ProgrammingTests.SubmissionsList questions={submissionData} />
      </div>
    )
  }

  _fetchData = () => {
    const { enrollmentId } = this.props
    const { selectedTest } = this.state

    this.setState({ fetching: true })

    const url = `http://localhost:3000/api/exams/${selectedTest}/students/${enrollmentId}`

    fetch(url)
      .then(resp => resp.json())
      .then(json => {
        this.setState({ submissionData: json })
      })
      .finally(() => {
        this._setPoller()
        this.setState({ fetching: false })
      })
  }

  _cancelPoller = () => {
    if (this.poller) {
      clearTimeout(this.poller)
      this.poller = null;
    }
  }

  _setPoller = () => {
    const { pollTimeout } = this.props

    this.poller = setTimeout(() => {
      this._fetchData()
    }, pollTimeout * 1000)
  }
}
