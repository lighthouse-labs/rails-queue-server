window.NationalQueue = window.NationalQueue || {};
const useState = React.useState;

const checkCollapsed = (title) => {
  return window.localStorage.getItem(`${title} - collapsed`) === 'y';
}

window.NationalQueue.ListGroup = ({children, count, title, open, toggleOpen}) => {
  const [collapsed, setCollapsed] = useState(checkCollapsed(title));

  const handleToggleCollapse = () => {
    toggleOpen();
    if (collapsed) {
      window.localStorage.setItem(`${title} - collapsed`, 'n');
    } else {
      window.localStorage.setItem(`${title} - collapsed`, 'y');
    }
  }

  return(
    <div className={`card card-default ${open && (count > 0 || count === '!') ? 'open' : 'collapsed'}`}>
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
