require 'fileutils'

class OnBoard
  module Virtualization
    module QEMU
      class Img

        ROOTDIR = ENV['HOME'] + 'files/QEMU'

        class << self

          def absolute_path(*a)
            QEMU::Config.absolute_path *a
          end

          def relative_path(*a)
            QEMU::Config.relative_path *a
          end

          # for example an image is created at: ~/files/qemu/Win7/Win7.qcow2
          # or ~/files/qemu/Debian/Debian.raw
          def create(h)
            raise OnBoard::BadRequest, 'Virtual machine must have a name' unless
                h[:http_params]['name'] and h[:http_params]['name'] =~ /\S/
            name = h[:http_params]['name']
            if h[:http_params]['qemu-img'] and h[:http_params]['qemu-img']['create'] == 'on'
              size_str = h[:http_params]['qemu-img']['size']['G'] + 'G'
              fmt = h[:http_params]['qemu-img']['fmt']
              FileUtils.mkdir_p File.join ROOTDIR, name
              filepath = "#{ROOTDIR}/#{name}/#{name}.#{fmt}"
              System::Command.run(
                  "qemu-img create -f #{fmt} '#{filepath}' #{size_str}", :raise_BadRequest) 
              return filepath
            end
          end

        end
      end
    end
  end
end

