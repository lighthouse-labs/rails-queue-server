window.Queue || (window.Queue = {});

class SocialIcon extends React.Component {
  propTypes: {
    company: PropTypes.string.isRequired,
    handle: PropTypes.string.isRequired,
    url: PropTypes.string,
  }

  render() {
    const { company, handle, url } = this.props;
    const iconSet = company == 'inbox' ? 'fas' : 'fab';
    return (
      <li className="list-inline-item">
        <a href={url || '#'} target={url ? '_blank' : ''} datatoggle="tooltip" title={handle}>
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

    return(
      <ul className="list-inline social-icons">
        <SocialIcon
          handle={user.email}
          company="inbox"
          url={`mailto:${user.email}`}
        />
        <SocialIcon
          handle={user.github_username}
          company="github"
          url={`https://github.com/${user.github_username}`}
        />
        <SocialIcon handle={user.slack} company="slack" />
      </ul>
    )
  }

}