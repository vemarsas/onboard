autoload :FileUtils, 'fileutils'
autoload :Filepath, 'filepath'

require 'onboard/crypto/ssl'
require 'onboard/crypto/easy-rsa'

class OnBoard
  module Crypto
    module EasyRSA
      module Multi

        SUBDIR = '__multipki__'

        class << self
          def handle_legacy
          end
          def add_pki(pkiname)
            pki = PKI.new(pkiname)
            pki.mkdir
          end
        end

        class PKI
          def initialize(name)
            @name = name
          end
          def mkdir
            FileUtils.mkdir_p File.join SSL::DATADIR, Multi::SUBDIR, @name
            FileUtils.mkdir_p File.join EasyRSA::DATADIR, Multi::SUBDIR, @name
          end
        end

      end
    end
  end
end

