class OnBoard
  module V12n 
    module QEMU
      ROOTDIR = File.dirname(__FILE__)
      # $LOAD_PATH.unshift  ROOTDIR + '/lib'
      if OnBoard.web?
        OnBoard.find_n_load ROOTDIR + '/etc/menu'
        OnBoard.find_n_load ROOTDIR + '/controller'
      end
    end
  end
  Virtualization = V12n 
end

