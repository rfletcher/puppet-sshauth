require "tmpdir"

module Puppet::Parser::Functions
  newfunction(
    :generate_keypair,
    :type => :rvalue,
    :doc  => "Generate a new SSH keypair"
  ) do |args|
    name = args.first

    opts = {
      'type'   => nil,
      'length' => nil
    }.merge( args[1] || {} )

    keypair = {}

    Dir.mktmpdir do |tmpdir|
      key_file = "#{tmpdir}/key"

      command = <<-SHELL
        ssh-keygen \
          -b "#{opts['length']}" \
          -C "#{name}" \
          -f "#{key_file}" \
          -N "" \
          -t "#{opts['type']}"
      SHELL

      %x{#{command}}

      keypair['private_key'] = File.read( key_file )
      keypair['public_key']  = File.read( "#{key_file}.pub" ).chomp.split( ' ' )[1]
    end

    keypair
  end
end
