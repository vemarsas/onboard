autoload :FileUtils, 'fileutils'
autoload :Filepath, 'filepath'

require 'onboard/crypto/ssl'
require 'onboard/crypto/ssl/multi'
require 'onboard/crypto/easy-rsa'

class OnBoard
  module Crypto
    module EasyRSA
      module Multi

        SUBDIR = SSL::Multi::SUBDIR
        DATADIR = File.join EasyRSA::DATADIR, SUBDIR
        DEFAULTPKIDIR = File.join DATADIR, 'default'

        class << self
          def handle_legacy
            SSL::Multi.handle_legacy
            unless File.exists? DEFAULTPKIDIR
              FileUtils.ln_s '..', DEFAULTPKIDIR
            end
          end
          def add_pki(pkiname)
            mkdir(pkiname)
          end
          def mkdir(pkiname)
            FileUtils.mkdir_p File.join SSL::DATADIR, Multi::SUBDIR, @name
            FileUtils.mkdir_p File.join EasyRSA::DATADIR, Multi::SUBDIR, @name
          end
        end

      end
    end
  end
end

