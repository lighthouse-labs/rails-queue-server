window.ProgrammingTests || (window.ProgrammingTests = {});

window.ProgrammingTests.StudentValidator = PropTypes.shape({
  name: PropTypes.string.isRequired,
  enrollmentId: PropTypes.string.isRequired
})

window.ProgrammingTests.App = class App extends React.Component {
  static propTypes = {
    programmingTests: PropTypes.array.isRequired,
    students: PropTypes.arrayOf(ProgrammingTests.StudentValidator).isRequired
  }

  constructor(props) {
    super(props)

    this.state = {
      selectedTab: props && props.programmingTests && props.programmingTests[0] && props.programmingTests[0].code || 0
    }
  }

  render() {
    const { programmingTests, students } = this.props
    const { selectedTab } = this.state

    return (
      <div>
        <ProgrammingTests.TabList programmingTests={programmingTests} selectedTab={selectedTab} onTabSelected={this._handleTabSelected} />

        <ProgrammingTests.ShowExamPage students={students} code={selectedTab} />
      </div>
    )
  }

  _handleTabSelected = (tab) => {
    this.setState({ selectedTab: tab })
  }
}
