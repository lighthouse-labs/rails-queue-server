window.NationalQueue = window.NationalQueue || {};
const useEffect = React.useEffect;
const useState = React.useState;
const useRef = React.useRef;

const SocialIcon = ({company, handle, url}) => {
  const iconRef = useRef();

  useEffect(() => {
    window.$(iconRef.current).tooltip();
  }, []);

  const iconSet = company === 'inbox' ? 'fas' : 'fab';
  return (
    <li className="list-inline-item">
      <a
        href={url || '#'}
        target={url ? '_blank' : ''}
        data-toggle="tooltip"
        title={handle}
        ref={iconRef}
      >
        <span className="fa-stack fa-lg social-icon-muted">
          <i className="far fa-square fa-stack-2x" />
          <i className={`${iconSet} fa-${company} fa-stack-1x`} style={{ top: -1 }} />
        </span>
      </a>
    </li>
  )
}

window.NationalQueue.SocialIcons = ({user}) => {
  return(
    <ul className="list-inline social-icons">
      {user.email && <SocialIcon
        handle={user.email}
        company="inbox"
        url={`mailto:${user.email}`}
      />}
      {user.githubUsername && <SocialIcon
        handle={user.githubUsername}
        company="github"
        url={`https://github.com/${user.githubUsername}`}
      />}
      {user.slack && <SocialIcon handle={user.slack} company="slack" />}
    </ul>
  );
}