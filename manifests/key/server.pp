# = Define: sshauth::key::server
#
# Install a public key into a server user's authorized_keys(5) file.
#
# This definition is private, i.e. it is not intended to be called directly by
# users. Called by sshauth::key to generate an exported resource and by
# sshauth::server to realize the resource tagged by namevar (the keyname).
#
# === Parameters: see sshauth::server
#
# === Usage:
#
# # from sshauth::key
# @@sshauth::key::server { $name:
#   ensure  => $ensure,
#   user    => $_user,
#   options => $options,
#   tag     => $_tag,
# }
#
# # from sshauth::server
# Sshauth::Key::Server <<| tag == $_tag |>>
define sshauth::key::server (
  $ensure,
  $user,
  $options,
) {
  # notify { "sshauth::key::server: ensure is= $ensure": }
  # notify { "sshauth::key::server: user is= $user": }
  # notify { "sshauth::key::server: options is= $options": }

  $keypair = get_ssh_keypair( $name )

  # if absent, remove from authorized_keys
  if $ensure == 'absent' {
    ssh_authorized_key { $name:
      ensure => $ensure,
      user   => $user,
    }

  # if no key content, do nothing. wait for keymaster to realise key resource
  } elsif ! $keypair {
    notify { "Public key for '${name}' not found; skipping": }

  # all's good. install the pubkey.
  } else {
    ssh_authorized_key { $name:
      ensure  => present,
      user    => $user,
      type    => $keypair['type'],
      key     => $keypair['public_key'],
      options => $options ? {
        ''      => undef,
        default => $options,
      },
    }
  }
}
