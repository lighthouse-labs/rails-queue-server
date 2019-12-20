window.ProgrammingTests || (window.ProgrammingTests = {});

window.ProgrammingTests.ShowExam = class ShowExam extends React.Component {
  static propTypes = {
    code: PropTypes.string.isRequired,
    students: PropTypes.arrayOf(PropTypes.shape({
      name: PropTypes.string.isRequired,
      enrollmentId: PropTypes.string.isRequired,
      detailsPath: PropTypes.string.isRequired
    })).isRequired,
    pollTimeout: PropTypes.number,
    proctorConfig: PropTypes.shape({
      baseUrl: PropTypes.string.isRequired,
      token: PropTypes.string.isRequired
    }).isRequired
  }

  static defaultProps = {
    pollTimeout: 7
  }

  constructor(props) {
    super(props)

    this.state = {
      examStats: {}
    }
  }

  componentDidMount() {
    this._fetchData()
  }

  componentDidUpdate(prevProps) {
    if (this.props.code !== prevProps.code) {
      this._fetchData();
    }
  }

  componentWillUnmount() {
    this._cancelPoller()
  }

  render() {
    const { code, students } = this.props
    const { examStats } = this.state
    const studentIds = Object.keys(examStats)

    return (
      <div>
        <ProgrammingTests.SummaryTable
          code={code}
          examStats={this.state.examStats}
          students={students}
        />

        <ProgrammingTests.MissingStudentsList students={students} received={studentIds} />
      </div>
    )
  }

  _fetchData = () => {
    const { code, students, proctorConfig } = this.props
    this._cancelPoller()

    const ids = students.map(s => s.enrollmentId)

    const url = `${proctorConfig.baseUrl}/api/v2/stats/${code}/?studentIds=${ids}`
    fetch(url, { headers: { 'Authorization': `Token token="${proctorConfig.token}"` } })
      .then(resp => resp.json())
      .then(json => {
        this.setState({ examStats: json })
      })
      .finally(() => {
        this._setPoller()
      })
  }

  _cancelPoller = () => {
    clearTimeout(this.poller);
  }

  _setPoller = () => {
    const { pollTimeout } = this.props

    this.poller = setTimeout(() => {
      this._fetchData();
    }, pollTimeout * 1000)
  }
}

window.ProgrammingTests.MissingStudentsList = class MissingStudentsList extends React.Component {
  render() {
    const { received } = this.props

    if (received.length === 0) {
      return null;
    }

    return (
      <div>
        <strong>Missing Students:</strong>

        {this._renderMissingStudents()}
      </div>
    )
  }

  _renderMissingStudents = () => {
    const { students, received } = this.props
    const nameMap = students.reduce((obj, student) => {
      obj[student.enrollmentId] = student.name
      return obj
    }, {})
    const expected = Object.keys(nameMap)
    debugger;

    const a = new Set(expected)
    const b = new Set(received)
    const missing = new Set([...a].filter(x => !b.has(x)))
    const arrLabels = []
    for (const username of missing) {
      arrLabels.push(
        <li className="list-group-item" key={username}>{nameMap[username]}</li>
      )
    }

    return (
      <ul className="list-group">
        {arrLabels}
      </ul>
    )
  }
}
