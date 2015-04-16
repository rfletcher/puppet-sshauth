module Puppet::Parser::Functions
  newfunction(
    :get_group, 
    :type => :rvalue, 
    :doc => "Returns primary group of user specified in args[0]"
  ) do |args|
    # get fact getent_passwd and convert it into hash of user entries
    gids = lookupvar( '::getent_passwd' ).split( '|' ).reduce( {} ) do |acc, item|
      user, pw, uid, gid, gecos, homedir, shell = item.split( ':' )

      acc.merge( user => ( gid || "" ) )
    end

    groups = lookupvar( '::getent_group' ).split( '|' ).reduce( {} ) do |acc, item|
      group,pw,gid = item.split(':')

      acc.merge( gid => ( group || "" ) )
    end

    # make sure args[0] is a strings
    if args[0].is_a?( String )
      groups[gids[args[0]]]

    else 
      Puppet.warning "get_group: usage: get_group( user )"

      nil
    end
  end
end
