autoload :FileUtils, 'fileutils'
autoload :Filepath, 'filepath'

require 'onboard/crypto/easy-rsa'

class OnBoard
  module Crypto
    module EasyRSA
      module Multi
        class << self
          def handle_legacy
          end
        end
      end
    end
  end
end

