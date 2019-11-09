require 'erb'
require 'openssl'
require 'facets/hash'
require 'onboard/crypto/ssl'

class OnBoard
  module Crypto
    module SSL
      module Multi

        SUBDIR = '__multipki__'
        DATADIR = File.join SSL::DATADIR, SUBDIR

        class << self
          def handle_legacy
          end

          def get_pkis
            if Dir.exists? DATADIR
              return Dir.entries(DATADIR).select{|entry| entry =~ /^[^\.]/i}
            else
              return []
            end
          end
        end

      end
    end
  end
end
