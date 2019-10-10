window.Queue || (window.Queue = {});

class SocialIcon extends React.Component {
  propTypes: {
    company: PropTypes.string.isRequired,
    handle: PropTypes.string.isRequired,
    url: PropTypes.string,
  }

  componentDidMount() {
    window.$('[data-toggle="tooltip"]').tooltip();
  }
  render() {
    const { company, handle, url } = this.props;
    const iconSet = company == 'inbox' ? 'fas' : 'fab';
    return (
      <li className="list-inline-item">
        <a
          href={url || '#'}
          target={url ? '_blank' : ''}
          data-toggle="tooltip"
          title={handle}
          ref={handle}
        >
          <span className="fa-stack fa-lg" style={{ fontSize: '0.9em' }}>
            <i className="far fa-square fa-stack-2x" />
            <i className={`${iconSet} fa-${company} fa-stack-1x`} style={{ top: -1 }} />
          </span>
        </a>
      </li>
    )
  }
}

window.Queue.SocialIcons = class SocialIcons extends React.Component {
  propTypes: {
    user: PropTypes.object.isRequired
  }

  render() {
    const user = this.props.user;
// console.log('user :', user);
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
    )
  }

}