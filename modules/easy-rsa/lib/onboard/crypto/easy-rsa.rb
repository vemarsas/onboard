require 'fileutils'

class OnBoard
  module Crypto

    autoload :SSL, 'onboard/crypto/ssl'

    module EasyRSA

      autoload :CA,   'onboard/crypto/easy-rsa/ca'
      autoload :Cert, 'onboard/crypto/easy-rsa/cert'

      SCRIPTDIR = OnBoard::ROOTDIR + '/modules/easy-rsa/easy-rsa/2.0'
      DATADIR = OnBoard::RWDIR + '/var/lib/crypto/easy-rsa'
      KEYDIR = DATADIR + '/keys'
      CRL = KEYDIR + '/crl.pem'

      class PKI
        def initialize(name)
          @name = name
        end

        def datadir
          File.join DATADIR, @name
        end
        def keydir
          File.join datadir, @name
        end

        def self.create_dh(n)
          FileUtils.mkdir_p keydir unless Dir.exists? keydir
          build_dh = 'build-dh'
          if n.respond_to? :to_i and n.to_i > 2048
            build_dh = 'build-dh.dsaparam'  # faster
          end
          System::Command.run <<EOF
cd #{SCRIPTDIR}
export KEY_DIR=#{keydir}
. ./vars
export KEY_SIZE=#{n}
./#{build_dh}
EOF
          sslpki = SSL::PKI.new @name
          FileUtils.mkdir_p sslpki.datadir unless Dir.exists? sslpki::datadir
          FileUtils.cp(keydir + '/dh' + n.to_s + '.pem', sslpki.datadir)
        end
      end
    end
  end
end

