window.ProgrammingTests || (window.ProgrammingTests = {})

window.ProgrammingTests.SummaryTable = class SummaryTable extends React.Component {
  static propTypes = {
    code: PropTypes.string.isRequired,
    examStats: PropTypes.object
  }

  render() {
    return (
      <table className="table table-striped table-bordered table-hover">
        <thead>
          <tr>{this._renderTableHeaders()}</tr>
        </thead>
        <tbody>
          {this._renderTableRows()}
        </tbody>
      </table>
    )
  }

  _renderTableHeaders = () => {
    const { examStats } = this.props
    let headers = ['Student']
    let questionHeaders
    for (let key in examStats) {
      questionHeaders = []
      for (let q of examStats[key].scores) {
        questionHeaders.push('Q' + q.questionNumber)
      }
    }
    headers = headers.concat(questionHeaders)
    headers.push(
      'Total (Initial)',
      'Total (Extended)',
      'Submission Count',
      'Last Submission'
    )
    let ret = []
    for (let idx in headers) {
      ret.push(
        <td key={idx}>
          <strong>{headers[idx]}</strong>
        </td>
      )
    }
    return ret
  }

  _renderTableRows = () => {
    const { students, examStats } = this.props
    const rows = []
    const getStudent = (id) => students.filter(s => s.enrollmentId === id)[0]

    for (let key in examStats) {
      const rowData = examStats[key]
      const student = getStudent(key)
      rows.push(
        <tr key={key}>
          <td>
            <a href={student.detailsPath}>
              <strong>{student.name}</strong>
            </a>
          </td>
          {this._renderQuestionScoreCells(rowData)}
          {this._renderFormattedScore(rowData, 'initial_total')}
          {this._renderFormattedScore(rowData, 'final_total')}
          <td>{rowData.count_submissions ? rowData.count_submissions : 0}</td>
          <td title={moment(rowData.last_submission).toString()}>
            {rowData.last_submission ? moment(rowData.last_submission).fromNow() : '-'}
          </td>
        </tr>
      )
    }
    return rows
  }

  _renderQuestionScoreCells = (rowData) => {
    const questionScores = []
    for (let q of rowData.scores) {
      questionScores.push(
        <td key={q.questionNumber}>
          <strong>{q.score}</strong> / {q.maxScore}
        </td>
      )
    }
    return questionScores
  }

  _renderFormattedScore = (rowData, field) => {
    if (!rowData || !rowData[field]) {
      return null
    }
    let totalMax = 0
    for (let q of rowData.scores) {
      totalMax += q.maxScore
    }
    const totalScore = parseFloat(rowData[field])
    const percentage = Math.round((100 * totalScore) / (totalMax || 1))
    return (
      <td>
        <strong>{totalScore}</strong> ({percentage}%)
      </td>
    )
  }
}
