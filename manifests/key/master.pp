# = Define: sshauth::key::master
#
# Create/regenerate/remove a key pair
#
# This definition is private, i.e. it is not intended to be called directly by
# users. ssh::auth::key calls it to create virtual keys, which are realized in
# ssh::auth::keymaster.
define sshauth::key::master (
  $ensure,
  $force,
  $type,
  $length,
  $maxdays,
  $mindate,
) {
  if $ensure == 'present' {
    $current_time = time()
    $keypair = get_ssh_keypair( $name )

    # determine whether keys need to be generated
    if ! $keypair {
      $generate_keys = true
    } else {
      # check if keys should be revoked
      if $force {
        $reason = "forced"

      } elsif $keypair['length'] != $length {
        $reason = "key length changed (${keypair['length']} -> $length)"

      } elsif $keypair['type'] != $type {
        $reason = "key type changed (${keypair['type']} -> $type)"

      } elsif is_integer( $mindate ) and $mindate > 0 and $keypair['created_at'] < $mindate {
        $reason = "key created before cutoff date (created at ${keypair['created_at']}, min. creation date is ${mindate})"

      } elsif is_integer( $maxdays ) and $maxdays > 0 and
              $current_time > ( $keypair['created_at'] + ( $maxdays * 60 * 60 * 24 ) ) {
        $reason = "key has expired (created at ${keypair['created_at']}, currently ${$current_time})"
      }

      if $reason {
        $generate_keys = true

        notify { "SSH key '${name}' revoked: ${reason}": }
      }
    }

    if ! $generate_keys {
      $params = $keypair
    } else {
      notify { "Generating new SSH key: ${name}": }

      $keys = generate_keypair( $name, {
        'length' => $length,
        'type'   => $type,
      } )

      $params = {
        'created_at'  => $current_time,
        'length'      => $length,
        'type'        => $type,
        'public_key'  => $keys['public_key'],
        'private_key' => $keys['private_key'],
      }
    }

    # save the keypair in puppetdb
    create_resources( '@@sshauth::key::pair', {
      "${name}" => $params
    } )
  }
}
