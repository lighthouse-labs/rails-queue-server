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
        <ul className="nav nav-tabs" role="tablist" id="programmingTestTab">
          {programmingTests.map(test =>
            <ProgrammingTests.TabItem
              key={test.code}
              test={test}
              active={test.code === selectedTab}
              onSelected={this._handleTabSelected}
            />
          )}
        </ul>

        <ProgrammingTests.ShowExamPage students={students} code={selectedTab} />
      </div>
    )
  }

  _handleTabSelected = (tab) => {
    this.setState({ selectedTab: tab })
  }
}

window.ProgrammingTests.TabItem = class TabItem extends React.Component {
  static propTypes = {
    active: PropTypes.bool,
    test: PropTypes.shape({
      name: PropTypes.string.isRequired,
      code: PropTypes.string.isRequired
    }).isRequired,
    onSelected: PropTypes.func
  }

  static defaultProps = {
    active: false
  }

  render() {
    const { test, active } = this.props

    return (
      <li className="nav-item" role="presentation">
        <a
          className={"nav-link" + (active ? " active" : "")}
          href="#"
          aria-controls={test.code}
          role="tab"
          data-toggle="tab"
          onClick={this._handleOnClick}
        >
          {test.name}
        </a>
      </li>
    )
  }

  _handleOnClick = (e) => {
    e.preventDefault()
    e.stopPropagation()

    const { onSelected, test } = this.props

    onSelected && onSelected(test.code)
  }
}
