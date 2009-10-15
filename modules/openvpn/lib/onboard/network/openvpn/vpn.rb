class OnBoard
  module Network
    module OpenVPN
      class VPN
        # get info on running OpenVPN instances
        def self.getAll
          ary = []
          # NOTE: it's assumed that configuration options are only
          # in config files, not cmdline args; TODO: parse cmdline too?   
          `pidof openvpn`.split.each do |pid|
            conffile = ''
            cwd = `sudo readlink /proc/#{pid}/cwd`.strip
            cmdline = File.read("/proc/#{pid}/cmdline").split("\0")
            cmdline.each_with_index do |arg, idx|
              next if idx == 0
              if 
                  cmdline[idx - 1] =~ /^\s*\-\-config/ or not 
                  cmdline[idx - 1] =~ /^\s*\-/
                conffile = File.join cwd, arg
              end
            end
            ary << self.new(
              :pid => pid,
              :conffile => conffile
            )
          end
          return ary
        end

        attr_reader :data

        def initialize(h) 
          @data = {}
          @data_internal = {
            :cwd => h[:cwd],
            :pid => h[:pid],
            :conffile => h[:conffile]
          } 
          parse_conffile()
        end

        def parse_conffile
          File.foreach @data_internal[:conffile] do |line|
=begin
# this is a comment
  #this too
a_statement # this is a comment # another comment
address#port # 'port' was not a comment (for example, dnsmasq config files) 
=end
            next if line =~ /^\s*[;#]/
            line.sub! /\s+[;#].*$/, '' 

            # "public" options with no arguments ("boolean" options)
            %w{duplicate-cn client-to-client}.each do |optname|
            end 

            # "public" options with an argument 
            %w{port proto dev max-clients ifconfig-pool-persist status log log-append}.each do |optname|
            end

            # "public" options with more arguments
            # server

            # "private" options with an argument
            %w{ca cert key dh}.each do |optname|
            end

            # TODO or not TODO
            # TODO? server-bridge
            # TODO? push routes
            # TODO? client-config-dir, route
            # TODO? push "redirect-gateway def1 bypass-dhcp"

          end 
        end

      end
    end
  end
end
