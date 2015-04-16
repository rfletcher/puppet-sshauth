sshauth
=======

sshauth provides centralized creation, distribution, and revocation of
ssh keys for users. This modules was adapted from the ssh::auth module by
Andrew E. Schulman <andrex at alumni dot utexas dot net>. For full
documentation of Andrew's version please refer to
http://projects.puppetlabs.com/projects/1/wiki/Module_Ssh_Auth_Patterns

I am expanding on the work Atha Kouroussis's sshauth module
https://github.com/vurbia/puppet-sshauth. This implementation has changed the
use of virtual resources to exported resources. While it adds the burden of
enabling storeconfigs, the main advantage is that keys can be declared
contextually and not at central location so the keymaster can see them.

#### Public Classes

- sshauth::client: Install generated key pairs onto clients.
- sshauth::key:    Declare keys as exported resources.
- sshauth::master: Create, regenerate, and remove key pairs.
- sshauth::server: Install public keys onto ssh servers.

#### Private Classes

These classes should not be used directly. Documented for completeness.

- sshauth::key::client:    Install a key pair into a user's account.
- sshauth::key::master:    Create/regenerate/remove a key pair on the keymaster.
- sshauth::key::namecheck: Check a name (e.g. key title or filename) for the allowed form.
- sshauth::key::pair:      Used purely as data storage for a keypair in PuppetDB.
- sshauth::key::server:    Install a public key into a server user's authorized_keys(5) file.

### Facts

- getent_passwd: Returns passwd entry for all users using "getent".
- getent_group:  Returns groups entry for all groups using "getent".

### Functions

- get_home_dir: Returns home directory name of user specified in args[0].
- get_group:    Returns primary group of user specified in args[0].

## Examples

### sshauth::master

Manage keys (creation, revocation). This class can only be included *one*
Puppet Master:

    include ::sshauth::master

### sshauth::key

Declare keypair named 'unixsys' with all defaults:

    ::sshauth::key { 'unixsys': }

Set alternate keyfile name for clients:

    ::sshauth::key { 'unixsys': filename => 'id_rsa-grall' }

Set user account for this key to agould. set encryption type to dsa:

    ::sshauth::key { 'unixsys': user => 'agould', type => 'dsa' }

Remove all instances of 'unixsys' keys on ssh clients, servers and keymaster:

    ::sshauth::key { 'unixsys': ensure => 'absent' }

### sshauth::client

Install keypair "unixsys" without overriding any original parameters:

    ::sshauth::client { 'unixsys': }

Override $user parameter on this client

    ::sshauth::client { 'unixsys': user => 'agould' }

Override $user and $filename parameters. This installs the 'unixsys' keypair
into agould's account with alternate keyname

    ::sshauth::client { 'unixsys': user => 'agould', filename => 'id_rsa-blee' }

Remove 'unixsys' keys from agould's account:

    ::sshauth::client { 'unixsys': user => 'agould', ensure => 'absent' }

### sshauth::server

Install unixsys pubkey into agould's authorized_keys file:

    ::sshauth::server { 'unixsys': user => 'agould' }

Install into agould's account, only allow client with ip 192.168.0.5:

    ::sshauth::server { 'unixsys': user => 'agould', options => "from '192.168.0.5'" }

Remove "unixsys" public key from agould's authorized_keys file:

    ::sshauth::server { 'unixsys': ensure => 'absent',user => 'agould' }
