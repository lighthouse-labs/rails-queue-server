window.ProgrammingTests || (window.ProgrammingTests = {})

window.ProgrammingTests.ShowExamPage = class ShowExamPage extends React.Component {
  static propTypes = {
    code: PropTypes.string.isRequired,
    students: PropTypes.arrayOf(ProgrammingTests.StudentValidator).isRequired,
    pollTimeout: PropTypes.number
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
    this._setPoller();
  }

  componentDidUpdate(prevProps) {
    if (this.props.code !== prevProps.code) {
      this._fetchData();
    }
  }

  render() {
    const { code, students } = this.props
    const gotStudentIds = Object.keys(this.state.examStats)
    const expectedIds = students.map(s => s.enrollmentId)

    return (
      <React.Fragment>
        <ProgrammingTests.SummaryTable
          code={code}
          examStats={this.state.examStats}
          students={students}
        />
        <span>
          <strong>Missing Students:</strong>
        </span>
        <div>{this._renderMissingStudents(students, expectedIds, gotStudentIds)}</div>
      </React.Fragment>
    )
  }

  _renderMissingStudents = (students, expected, received) => {
    const nameMap = students.reduce((obj, student) => {
      obj[student.enrollmentId] = student.name
      return obj
    }, {})

    const a = new Set(expected)
    const b = new Set(received)
    const missing = new Set([...a].filter(x => !b.has(x)))
    const arrLabels = []
    for (const username of missing) {
      arrLabels.push(
        <li className="list-group-item" key={username}>{nameMap[username]}</li>
      )
    }
    if (arrLabels.length === 0) {
      return (
        <span>
          <i>(None)</i>
        </span>
      )
    }

    return (
      <ul className="list-group">
        {arrLabels}
      </ul>
    )
  }

  _fetchData = () => {
    const { code, students } = this.props
    this._cancelPoller()

    const ids = students.map(s => s.enrollmentId)

    const url = `http://localhost:3000/api/exams/${code}/?studentIds=${ids}`
    fetch(url)
      .then(resp => resp.json())
      .then(json => {
        this.setState({ examStats: json })
        this._setPoller()
      })
  }

  _cancelPoller = () => {
    if (this.poller) {
      clearTimeout(this.poller);
      this.poller = null;
    }
  }

  _setPoller = () => {
    const { pollTimeout } = this.props

    this.poller = setTimeout(() => {
      this._fetchData();
    }, pollTimeout * 1000)
  }
}
