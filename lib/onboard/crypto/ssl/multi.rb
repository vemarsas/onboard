require 'erb'
require 'openssl'
require 'facets/hash'
require 'onboard/crypto/ssl'

class OnBoard
  module Crypto
    module SSL
      module Multi
        class << self
          def get_pkis
            return ['legacy']
          end
          def handle_legacy
          end
        end
      end
    end
  end
end
