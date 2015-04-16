# = Define: sshauth::key
#
# Declare keys. The approach here is just to define a bunch of virtual
# resources, representing key files on the keymaster, client, and server. The
# virtual keys are then realized by sshauth::{keymaster,client,server},
# respectively. The reason for doing things that way is that it makes
# sshauth::key into a "one stop shop" where users can declare their keys with
# all of their parameters, whether those parameters apply to the keymaster,
# server, or client. The real work of creating, installing, and removing keys is
# done in the private definitions called by the virtual resources:
# sshauth::key::{master,server,client}.
#
# === Provides:
#
# - Generate exported resources sshauth::key::{master,server,client} for named ssh key.
#
# === Parameters:
#
# $ensure:   Default: "present". Install or remove ssh keys. Setting to "absent"
#            removes all instances of the named key for ssh clients, servers and
#            the keymaster.
# $force:    Default: "false". Forces regeneration of the target key on each
#            puppet run. mindate parameter is better.
# $filename: Alternate name of private key when installed on clients. Public key
#            becomes ${filename}.pub.
# $length:   Default: "2048". The number of bits in the key to create.
#            (-b option in ssh-keygen)
# $mindate:  Date on which to revoke, recreate and redistribute sshkeys.
# $maxdays:  Recreate keys every $maxdays days.
# $options:  Options for public key when installed on server (authorized_keys).
# $type:     Default: "rsa". Type of key to create. (-t option in ssh-keygen)
# $user:     Default: namevar of this define. Username associated with this key.
#            Can be overriden in sshauth::client and sshauth::server.
#
# === Usage:
#
# # declare keypair named 'unixsys' with all defaults.
# sshauth::key { "unixsys": }
#
# # set alternate keyfile name for clients
# sshauth::key { "unixsys": filename => 'id_rsa-grall' }
#
# # set user account for this key to agould. set encryption type to dsa.
# sshauth::key { "unixsys": user => "agould", type => "dsa" }
#
# # remove all instances of 'unixsys' keys on ssh clients, servers and keymaster.
# sshauth::key { "unixsys": ensure => 'absent' }
#
define sshauth::key (
  $ensure   = present,
  $filename = '',
  $force    = false,
  $length   = 2048,
  $maxdays  = '',
  $mindate  = 1429117979,
  $options  = '',
  $type     = 'rsa',
  $user     = '',
) {
  # parse parameters. set values from defaults.
  $_user = $user ? {
    # take $user from namevar
    ''      => $name,
    default => $user,
  }

  $_filename = $filename ? {
    ''      => "id_${type}",
    default => $filename,
  }

  $_length = $type ? {
    'rsa' => $length,
    'dsa' => 1024,
  }

  $_tag = regsubst( $name, '@', '_at_' )


  # verify syntax of keyname/filename
  sshauth::key::namecheck { "${name}-name":
    param => 'name',
    value => $name,
  }
  sshauth::key::namecheck { "${name}-filename":
    param => 'filename',
    value => $_filename,
  }


  # generate exported resources for the keymaster to realize
  @@sshauth::key::master { $name:
    ensure  => $ensure,
    force   => $force,
    type    => $type,
    length  => $_length,
    maxdays => $maxdays,
    mindate => $mindate,
    tag     => $_tag,
  }

  # generate exported resources for the ssh client host to realize
  @@sshauth::key::client { $name:
    ensure   => $ensure,
    filename => $_filename,
    user     => $_user,
    tag      => $_tag,
  }

  # generate exported resources for the ssh server host to realize
  @@sshauth::key::server { $name:
    ensure  => $ensure,
    user    => $_user,
    options => $options,
    tag     => $_tag,
  }
}
