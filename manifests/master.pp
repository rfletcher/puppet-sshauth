# = Class: sshauth::master
#
# The key master creates, regenerates and removes key pairs.
# 
# === Provides:
#
# - Key managment
#
# === Requires:
#
# This class must be included on *one* puppet master server only.
#
# === Usage:
#
#   include ::sshauth::master
#
class sshauth::master {
  # Collect all exported key requests
  Sshauth::Key::Master <<| |>>
}
