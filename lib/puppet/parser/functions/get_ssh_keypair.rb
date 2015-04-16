module Puppet::Parser::Functions
  newfunction(
    :get_ssh_keypair,
    :type => :rvalue,
    :doc  => "Get a stored SSH keypair"
  ) do |args|
    name = args.first

    unless Puppet::Parser::Functions.autoloader.loaded?( :pdbquery )
      Puppet::Parser::Functions.autoloader.load( :pdbquery )
    end

    results = function_pdbquery( [ 'resources', [ 'and',
      [ '=', 'type',  'Sshauth::Key::Pair' ],
      [ '=', 'title', name                 ]
    ] ] )

    results.first['parameters'] rescue nil
  end
end
