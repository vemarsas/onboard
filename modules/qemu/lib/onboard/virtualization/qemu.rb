require 'yaml'
require 'uuid'
require 'fileutils'

require 'onboard/extensions/process'

class OnBoard
  module Virtualization
    module QEMU

      # TODO: do not hardcode so badly 
      FILESDIR = '/home/onboard/files'

      DEFAULT_SNAPSHOT = '_last'

      autoload :Config,   'onboard/virtualization/qemu/config'
      autoload :Instance, 'onboard/virtualization/qemu/instance'
      autoload :Img,      'onboard/virtualization/qemu/img'
      autoload :Monitor,  'onboard/virtualization/qemu/monitor'
      autoload :Network,  'onboard/virtualization/qemu/network'
      autoload :VNC,      'onboard/virtualization/qemu/vnc'

      class << self

        def get_all
          ary = []
          Dir.glob "#{CONFDIR}/*.yml" do |file|
            config = Config.new(:config => YAML.load(File.read file)) 
            ary << Instance.new(config)
          end
          return ary
        end

        def find(h)
          Dir.glob "#{CONFDIR}/*.yml" do |file|
            config = Config.new(:config => YAML.load(File.read file))
            if config.uuid =~ /^#{h[:vmid]}/
              return Instance.new(config)
            end
          end
        end

        def manage(h)
          all = get_all
          if h[:http_params]
            params = h[:http_params]
            %w{
start start_paused pause resume powerdown savevm_quit quit delete
            }.each do |cmd|
              if params[cmd] and params[cmd]['uuid']
                vm = all.find{|x| x.uuid == params[cmd]['uuid']} 
                vm.send cmd
              end
            end
            # eject / change removable media: cdrom etc.
            params['drive'].each_pair do |vm_uuid, drives|
              vm = all.find{|x| x.uuid == vm_uuid} 
              drives.each_pair do |drive_name, drive|
                if    drive['action'] == 'eject'
                  vm.drive_eject  drive_name
                  vm.drive_save   drive_name, nil
                elsif drive['action'] == 'change'         and 
                    not drive['file'] =~ /^\s*\[.*\]\s*$/
                        # special messages like '[choose an image]' 
                  drive_file = QEMU::Img.absolute_path drive['file']
                  vm.drive_change drive_name, drive_file
                  vm.drive_save   drive_name, drive_file
                end
              end
            end if params['drive'].respond_to? :each_pair 
          end
        end

        def cleanup
          Dir.glob "#{VARRUN}/qemu-*.pid" do |pidfile|
            pidfile =~ /qemu-(.*)\.pid/ and vmid = $1
            unless Process.running? File.read(pidfile).to_i
              Dir.glob "#{VARRUN}/qemu-#{vmid}.*" do |file|
                FileUtils.rm_f file 
              end
            end
          end
        end

      end

    end
  end
end
