class OnBoard
  module Crypto
    module SSL
      DATADIR               = OnBoard::CONFDIR + '/crypto/ssl'
      DIR                   = DATADIR
      KEY_SIZES             = [4096, 2048, 1024]
    end
  end
end

