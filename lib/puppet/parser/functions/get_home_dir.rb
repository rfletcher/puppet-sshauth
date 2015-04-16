module Puppet::Parser::Functions
  newfunction(
    :get_home_dir, 
    :type => :rvalue, 
    :doc  => "Returns home directory name of user specified in args[0]"
  ) do |args|
    # get fact getent_passwd and convert it into hash of user entries
    dirs = lookupvar( '::getent_passwd' ).split( '|' ).reduce( {} ) do |acc, item|
      user, pw, uid, gid, gecos, homedir, shell = item.split( ':' )

      acc.merge( user => ( homedir || "" ) )
    end

    # make sure args[0] is a strings
    if args[0].is_a?( String )
      dirs[args[0]]
    else 
      Puppet.warning "get_home_dir: usage: get_home_dir( user )"

      nil
    end
  end
end
