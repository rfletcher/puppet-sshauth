# = Define: sshauth::key::client
#
# Install a key pair into a user's account.
#
# This definition is private, i.e. it is not intended to be called directly by
# users. Called by sshauth::key to generate an exported resource and by
# sshauth::client to realize the resource tagged by namevar (the keyname).
#
# === Parameters: see sshauth::client
#
# === Usage:
#
# # from sshauth::key
# @@sshauth::key::client { $name:
#   ensure   => $ensure,
#   filename => $_filename,
#   user     => $_user,
#   tag      => $_tag,
# }
#
# # from sshauth::client
# Sshauth::Key::Client <<| tag == $_tag |>>
#
define sshauth::key::client (
  $ensure,
  $filename,
  $user,
) {
  # get homedir and primary group of $user
  $home  = get_home_dir( $user )
  $group = get_group( $user )
  # notify { "sshauth::key::client: user is= $user": }
  # notify { "sshauth::key::client: home is= $home": }
  # notify { "sshauth::key::client: group is= $group": }
  # notify { "sshauth::key::client: ensure is= $ensure": }

  # filename of private key on the ssh client host (target)
  $key_tgt_file = "${home}/.ssh/${filename}"

  $keypair = get_ssh_keypair( $name )

  # if 'absent', revoke the client keys
  if $ensure == 'absent' {
    file { [
      $key_tgt_file,
      "${key_tgt_file}.pub"
    ]:
      ensure => $ensure
    }

  # test for homedir and primary group
  } elsif ! $home {
    # notify { "Can't determine home directory of user $user": }
    err( "Can't determine home directory of user $user" )

  } elsif ! $group {
    # notify { "Can't determine primary group of user $user": }
    err( "Can't determine primary group of user $user" )

  } elsif ! $keypair {
    notify { "Private key for '${name}' not found; skipping": }

  # install keypair on client
  } else {
    # QUESTION: what about the homedir?  should we create that if 
    # not defined also? I think not.
    #
    # create client user's .ssh file if defined already
    if ! defined( File["${home}/.ssh"] ) {
      file { "${home}/.ssh":
        ensure => directory,
        owner  => $user,
        group  => $group,
        mode   => '700',
      }
    }

    file { $key_tgt_file:
      content => $keypair['private_key'],
      owner   => $user,
      group   => $group,
      mode    => '0600',
      require => File["${home}/.ssh"],
    }

    file { "${key_tgt_file}.pub":
      content => $keypair['public_key'],
      owner   => $user,
      group   => $group,
      mode    => '0644',
      require => File["${home}/.ssh"],
    }
  }
}
