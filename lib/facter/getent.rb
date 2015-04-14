# getent.rb
# Tue Dec 18 13:53:39 PST 2012
# agould@ucop.edu


require 'facter'

# Returns passwd entry for all users using "getent".
Facter.add( :getent_passwd ) do
  users = %x{/usr/bin/getent passwd}.split( "\n" ).join( "|" )

  setcode do
    users
  end
end

# Returns groups entry for all groups using "getent".
Facter.add( :getent_group ) do
  groups = %x{/usr/bin/getent group}.split( "\n" ).join( "|" )

  setcode do
    groups
  end
end
