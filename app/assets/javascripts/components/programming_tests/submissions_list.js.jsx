window.ProgrammingTests || (window.ProgrammingTests = {})

window.ProgrammingTests.SubmissionsList = class SubmissionsList extends React.Component {
  static propTypes = {
    questions: PropTypes.array.isRequired
  }

  render() {
    const { questions } = this.props

    return (
      <div>
        {Object.keys(questions).map(questionNumber => (
          <ProgrammingTests.QuestionDetail
            key={questionNumber}
            question={questions[questionNumber]}
          />
        ))}
      </div>
    )
  }
}

window.ProgrammingTests.QuestionDetail = class QuestionDetail extends React.Component {
  render() {
    const { question } = this.props

    return (
      <div className="card">
        <div className="card-header">Question {question.question_number} ({moment(question.created_at).fromNow()})</div>

        <div className="card-body">
          <h4>Summary</h4>

          <ProgrammingTests.QuestionSummary question={question} />

          <h4>Lint Results</h4>

          <ProgrammingTests.LintResults results={question.lint_results.lint} />

          <h4>Student Code</h4>

          <ProgrammingTests.CodeView code={question.student_code} />
        </div>
      </div>
    )
  }
}

window.ProgrammingTests.CodeView = class CodeView extends React.Component {
  static propTypes = {
    code: PropTypes.string.isRequired
  }

  constructor() {
    super()

    this.editorRef = React.createRef()
  }

  componentDidMount() {
    const { code } = this.props

    this.editor = ace.edit(this.editorRef.current)
    this.editor.setTheme('ace/theme/monokai')
    this.editor.setReadOnly(true)

    const editorSession = ace.createEditSession(code, 'ace/mode/javascript')
    this.editor.setSession(editorSession)
  }

  componentDidUpdate(prevProps) {
    const { code } = this.props

    if (code !== prevProps.code) {
      const editSession = ace.createEditSession(code, 'ace/mode/javascript')
      this.editor.setSession(editSession)
    }
  }

  render() {
    return (
      <div ref={this.editorRef} style={{ width: "100%", position: 'relative', height: '400px' }} />
    )
  }
}

window.ProgrammingTests.QuestionSummary = class QuestionSummary extends React.Component {
  render() {
    const { question } = this.props

    return (
      <table className="table table-bordered table-hover" style={{ overflowX: 'scroll' }}>
        <thead>
          <tr>
            <th>Date Submitted</th>
            <th>Unit Tests Passed</th>
            <th>Lint Issues</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td>{moment(question.created_at).toString()}</td>
            <td>{this._renderTestSummary()}</td>
            <td>{this._renderLintSummary()}</td>
          </tr>
        </tbody>
      </table>
    )
  }

  _renderLintSummary = () => {
    const { question } = this.props
    const lintResults = question.lint_results.lint
    if (!lintResults) {
      return 'N/A'
    }

    return lintResults.length
  }

  _renderTestSummary = () => {
    const { question } = this.props
    const testResults = question.test_results

    if (!testResults) {
      return 'N/A'
    } else {
      const testsPassed = testResults['passes']
      const testsTotal = testResults['tests']
      const percentage = Math.round((100 * testsPassed) / (testsTotal || 1))
      return `${testsPassed} of ${testsTotal} (${percentage}%)`
    }
  }
}

window.ProgrammingTests.LintResults = class LintResults extends React.Component {
  render() {
    const { results } = this.props

    if (!results || results.length === 0) {
      return (
        <span>
          <i>(No Lint Issues)</i>
        </span>
      )
    }
    return (
      <table className="table table-bordered table-hover">
        <thead>
          <tr>
            <th>Line</th>
            <th>Column</th>
            <th>Rule</th>
            <th>Message</th>
          </tr>
        </thead>
        <tbody>
          {
            results.map(result =>
              <tr key={`${result.line}-${result.column}-${result.ruleId}`}>
                <td><code>{result.line}</code></td>
                <td><code>{result.column}</code></td>
                <td><code>{result.ruleId}</code></td>
                <td><code>{result.message}</code></td>
              </tr>)
          }
        </tbody>
      </table>
    )
  }
}
