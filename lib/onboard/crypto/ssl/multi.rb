require 'fileutils'
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
        DEFAULTPKIDIR = File.join DATADIR, 'default'

        class << self
          def handle_legacy
            unless File.exists? DEFAULTPKIDIR
              FileUtils.ln_s '..', DEFAULTPKIDIR
            end
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
