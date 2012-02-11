gem 'uuid'

autoload :UUID, 'uuid'

class OnBoard
  module Virtualization
    module QEMU
      class Config

        autoload :Common, 'onboard/virtualization/qemu/config/common'
        autoload :Drive,  'onboard/virtualization/qemu/config/drive'

        # paste from man page
        KEYBOARD_LAYOUTS = %w{ 
            ar  de-ch  es  fo     fr-ca  hu  ja  mk     no  pt-br  sv
            da  en-gb  et  fr     fr-ch  is  lt  nl     pl  ru     th
            de  en-us  fi  fr-be  hr     it  lv  nl-be  pt  sl     tr        
        }.sort

        class << self

          def absolute_path(path)
            return path if path =~ /^\//
            return File.join FILESDIR, path
          end

          def relative_path(path)
            return nil unless path
            return path.sub /^#{FILESDIR}\//, ''
          end

        end

        attr_reader :uuid, :cmd

        def [](k)
          @cmd['opts'][k] 
        end

        def []=(k, val)
          @cmd['opts'][k] = val
        end 

        def initialize(h)
          if h[:http_params]
            @uuid = UUID.generate # creation from POST
            @cmd  = {
              #'exe'   => 'kvm',
              'opts'  => {
                '-enable-kvm' => true,
                '-uuid'       => @uuid,
                '-name'       => h[:http_params]['name'],
                '-m'          => h[:http_params]['m'].to_i,
                '-vnc'        => h[:http_params]['vnc'],
                '-k'          => h[:http_params]['k'], 
                #'-drive'     => [
                #  {
                #    'file'     => h[:http_params]['disk'], 
                #    'media'    => 'disk',
                #    'index'    => 0
                #  }
                #],
                '-daemonize'  => true,
                '-monitor'    => {
                  'unix'        => "#{VARRUN}/qemu-#{uuid_short}.sock",
                  'server'      => true,
                  'nowait'      => true
                },
                '-pidfile'    => "#{VARRUN}/qemu-#{uuid_short}.pid"
              }
            }
            if h[:http_params]['disk'] =~ /\S/
              @cmd['opts']['-drive'] ||= []
              @cmd['opts']['-drive'] << {
                'serial'=> generate_drive_serial,
                'file'  => self.class.absolute_path(h[:http_params]['disk']),
                'media' => 'disk',
                'if'    => 'ide',   # IDE (default)
                'bus'   => 0,       # Primary
                'unit'  => 0,       # Master
                'cache' => 'unsafe' # Dramatically improve performance on
                                    # savevm / loadvm
              }
            end
            @cmd['opts']['-drive'] ||= []
            @cmd['opts']['-drive'] << {
              'serial'=> generate_drive_serial, 
              'file'  => (
                self.class.absolute_path(h[:http_params]['cdrom']) if 
                    h[:http_params]['cdrom'] =~ /\S/  
              ),
              'media' => 'cdrom',
              'if'    => 'ide',     # IDE (default)
              'bus'   => 1,         # Secondary
              'unit'  => 0,         # Master
            }
          else
            @uuid = h[:config]['uuid']
            @cmd  = h[:config]['cmd']
          end
        end

        def generate_drive_serial
          return ('QM' + uuid_short + sprintf('%02x', drive_counter)).upcase
        end

        def drive_counter
          if @cmd['opts'] and @cmd['opts']['-drive'].respond_to? :length
            @cmd['opts']['-drive'].length
          else
            0
          end
        end

        def uuid_short
          @uuid.split('-')[0] 
        end

        def opts
          @cmd['opts']
        end

        def to_h
          {
            'uuid'  => @uuid,
            'cmd'   => @cmd 
          }
        end

        def to_json(*a); to_h.to_json(*a); end

        def file
          File.join QEMU::CONFDIR, "#@uuid.yml"
        end

        def save
          yaml_file = file
          File.open yaml_file, 'w' do |f|
            f.write YAML.dump to_h 
          end
        end

      end
    end
  end
end
