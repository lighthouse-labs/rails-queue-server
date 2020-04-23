window.NationalQueue = window.NationalQueue || {};
const useState = React.useState;

const checkCollapsed = (title) => {
  return window.localStorage.getItem(`${title} - collapsed`) === 'y';
}

window.NationalQueue.ListGroup = ({children, count, title}) => {
  const [collapsed, setCollapsed] = useState(checkCollapsed(title));

  const handleToggleCollapse = () => {
    if (collapsed) {
      setCollapsed(false);
      window.localStorage.setItem(`${title} - collapsed`, 'n');
    } else {
      setCollapsed(true);
      window.localStorage.setItem(`${title} - collapsed`, 'y');
    }
  }

  return(
    <div className={`card card-default ${collapsed ? 'collapsed' : ''}`}>
      <div className="card-header clearfix" onClick={handleToggleCollapse}>
        <h5 className="card-title">
          <span className="count">{count}</span>
          <span className="title">{title}</span>
        </h5>
      </div>
      <ul className="list-group">
        { children }
      </ul>
    </div>
  )
}
