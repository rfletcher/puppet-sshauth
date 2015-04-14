# = Define: sshauth::key::namecheck
#
# Check a name (e.g. key title or filename) for the allowed form
define sshauth::key::namecheck(
  $param,
  $value
) {
  if $value !~ /^[A-Za-z0-9]/ {
    fail( "sshauth::key: ${param} '${value}' not allowed: must begin with a letter or digit" )
  }

  if $value !~ /^[A-Za-z0-9_.:@-]+$/ {
    fail( "sshauth::key: ${param} '${value}' not allowed: may only contain the characters A-Za-z0-9_.:@-" )
  }
}
