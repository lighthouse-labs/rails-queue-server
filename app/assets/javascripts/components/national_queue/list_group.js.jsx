window.NationalQueue = window.NationalQueue || {};
const useState = React.useState;

const checkCollapsed = (title) => {
  return window.localStorage.getItem(`${title} - collapsed`) === 'y';
}

window.NationalQueue.ListGroup = ({children, icon, title}) => {
  const [collapsed, setCollapsed] = useState(checkCollapsed(title));

  const handleToggleCollapse = () => {
    setCollapsed(!collapsed);
    if (collapsed) {
      window.localStorage.setItem(`${title} - collapsed`, 'n');
    } else {
      window.localStorage.setItem(`${title} - collapsed`, 'y');
    }
  }

  return(
    <div className={`card card-default ${collapsed ? 'collapsed' : 'open'}`}>
      <div className="card-header-back"></div>
      <div className="card-header-border"></div>
      <div className="card-header clearfix" onClick={handleToggleCollapse}>
        <h5 className="card-title">
          <span className="count">{icon}</span>
          <span className="title">{title}</span>
        </h5>
      </div>
      <ul className="list-group">
        { children }
      </ul>
    </div>
  )
}
