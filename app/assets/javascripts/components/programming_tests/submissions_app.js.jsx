window.ProgrammingTests || (window.ProgrammingTests = {})

window.ProgrammingTests.SubmissionsApp = class SubmissionsApp extends React.Component {
  static propTypes = {
    student: PropTypes.shape({
      name: PropTypes.string.isRequired,
      enrollmentId: PropTypes.string.isRequired,
    }).isRequired,
    code: PropTypes.string.isRequired,
    pollTimeout: PropTypes.number
  }

  static defaultProps = {
    pollTimeout: 7
  }

  constructor(props) {
    super(props)

    this.state = {
      submissionData: [],
      summaryData: [],
      fetching: false
    }
  }

  componentDidMount() {
    this._fetchData()
  }

  componentWillUnmount() {
    this._cancelPoller()
  }

  render() {
    const { code, student } = this.props
    const { submissionData, summaryData } = this.state

    return (
      <div>
        <ProgrammingTests.SummaryTable code={code} examStats={summaryData} students={[student]} />
        <ProgrammingTests.SubmissionsList questions={submissionData} />
      </div>
    )
  }

  _fetchData = () => {
    this.setState({ fetching: true })

    Promise.all([
      this._fetchStudentSubmission(),
      this._fetchStudentSummary()
    ])
      .then(([submissions, summary]) => {
        this.setState({ submissionData: submissions, summaryData: summary })
      })
      .finally(() => {
        this._setPoller()
        this.setState({ fetching: false })
      })
  }

  _fetchStudentSummary = () => {
    const { student, code } = this.props

    const url = `http://localhost:3000/api/v2/stats/${code}/?studentIds=${student.enrollmentId}`
    return fetch(url)
      .then(resp => resp.json())
  }

  _fetchStudentSubmission = () => {
    const { student, code } = this.props

    const url = `http://localhost:3000/api/v2/stats/${code}/students/${student.enrollmentId}`

    return fetch(url)
      .then(resp => resp.json())
  }

  _cancelPoller = () => {
    clearTimeout(this.poller)
  }

  _setPoller = () => {
    const { pollTimeout } = this.props

    this.poller = setTimeout(() => {
      this._fetchData()
    }, pollTimeout * 1000)
  }
}
