#require 'fileutils'

#require 'onboard/extensions/ipaddr'
#require 'onboard/system/process'
#require 'onboard/network/interface'
#require 'onboard/network/interface/ip'

class OnBoard
  module Network
    module AP
      def self.set_config(ifname, params)
        File.open CONFDIR + '/new/' + ifname + '.conf', 'w' do |f|
          f.puts "interface=#{ifname}"
          %w{driver ssid channel country_code}.each do |k|
            v = params[k]
            f.puts "#{k}=#{v}" if v =~ /\S/
          end
          case params['mode']
          when 'a', 'b', 'g', 'ad'
            f.puts "hw_mode=#{params['mode']}"
          when 'n_5', 'n5'
            f.puts 'ieee80211n=1'
            f.puts 'hw_mode=a'
          when 'n_2.4', 'n2.4'
            f.puts 'ieee80211n=1'
            f.puts 'hw_mode=g'
          when 'ac'
            f.puts 'ieee80211ac=1'
            f.puts 'hw_mode=a'
          end
          if params['passphrase'].respond_to? :length and params['passphrase'].length > 0
            f.puts <<-EOF
# Use WPA authentication
auth_algs=1
# Use WPA2
wpa=2
# Use a pre-shared key
wpa_key_mgmt=WPA-PSK
# The network passphrase
wpa_passphrase=#{params['passphrase']}
EOF
          end
        end
      end

      def self.get_config(ifname)
        parse = {}
        res = {}
        File.readlines(CONFDIR + '/new/' + ifname + '.conf').each do |line|
          if line =~ /^\s*([^#\s]+)\s*=\s*([^#\s]+)/  # Assuming no spaces in values.
            parse[$1.strip] = $2.strip  # Redundant, but in case we include spaces above...
          end
        end
        %w{driver ssid channel country_code wpa}.each do |k|
          res[k] = parse[k]
        end
        if parse['ieee80211ac'] == '1'
          res['mode'] = 'ac'
        elsif parse['ieee80211n'] == '1'
          if parse['hw_mode'] == 'g'
            res['mode'] = 'n_2.4'
          elsif parse['hw_mode'] == 'a'
            res['mode'] = 'n_5'
          end
        else
          res['mode'] = parse['hw_mode']
        end
        res['passphrase'] = parse['wpa_passphrase']
        return res
      end

      def self.save
      end

      def self.restore
      end
    end
  end
end

