window.ProgrammingTests || (window.ProgrammingTests = {})

window.ProgrammingTests.TabList = class TabList extends React.Component {
  static propTypes = {
    programmingTests: PropTypes.arrayOf(PropTypes.object).isRequired,
    selectedTab: PropTypes.string.isRequired,
    onTabSelected: PropTypes.func.isRequired
  }

  render() {
    const { programmingTests, selectedTab } = this.props

    return (
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
    )
  }

  _handleTabSelected = (id) => {
    this.props.onTabSelected(id)
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
