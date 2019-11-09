autoload :FileUtils, 'fileutils'
autoload :Filepath, 'filepath'

require 'onboard/crypto/ssl'
require 'onboard/crypto/easy-rsa'

class OnBoard
  module Crypto
    module EasyRSA
      module Multi

        class << self
          def handle_legacy
          end
          def add_pki(pkiname)
            pki = PKI.new(pkiname)
            pki.mkdir
            FileUtils.mkdir_p File.join KEYDIR, pkiname
          end
        end

        class PKI
          def initialize(name)
            @name = name
          end
          def mkdir
            FileUtils.mkdir_p File.join SSL::CERTDIR, @name
            FileUtils.mkdir_p File.join SSL::KEYDIR, @name
            FileUtils.mkdir_p File.join EasyRSA::KEYDIR, @name
          end
        end

      end
    end
  end
end

