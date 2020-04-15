window.NationalQueue = window.NationalQueue || {};

window.NationalQueue.QueueItem = ({type, label, children, disabled}) => {
  return(
    <li className={`${_.kebabCase(type)} ${disabled} list-group-item clearfix`}>
      <div className="type">
        <div className="text">{ label || type }</div>
      </div>
      { children }
    </li>
  );
}