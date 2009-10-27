require 'sinatra/base'

class OnBoard
  module Network
    module OpenVPN
      autoload :VPN, 'onboard/network/openvpn/vpn'
    end
  end
end

class OnBoard::Controller < Sinatra::Base

  get '/network/openvpn.:format' do
    vpns = OnBoard::Network::OpenVPN::VPN.getAll()
    format(
      :module => 'openvpn',
      :path => '/network/openvpn/vpn',
      :format => params[:format],
      :objects  => vpns
    )
  end

  put '/network/openvpn.:format' do
    vpns = OnBoard::Network::OpenVPN::VPN.getAll()
    msg = OnBoard::Network::OpenVPN::VPN.modify_from_HTTP_request(params) 
    vpns = OnBoard::Network::OpenVPN::VPN.getAll()
    # Bringin' an OpenVPN connection up is an asynchronous operation,
    # while bringing it down is synchronous.
    if params['start']
      status(202)                         # HTTP 'Accepted'
    elsif params['stop']
      if not msg[:ok] and msg[:stderr]
        status(409)                       # HTTP 'Conflict'
      else
        status(200)                       # HTTP 'OK'
      end
    end
    format(
      :module   => 'openvpn',
      :path     => '/network/openvpn/vpn',
      :format   => params[:format],
      :objects  => vpns,
      :msg      => msg
    )
  end

  # modeled on DELETE bridge; TODO: DRY 
  delete '/network/openvpn/vpn/:vpnid.:format' do
    index = params[:vpnid].to_i - 1
    if vpn = OnBoard::Network::OpenVPN::VPN.getAll[index]
      vpn.stop()
      OnBoard::Network::OpenVPN::VPN.all_cached.delete_at index
      redirection = "/network/openvpn.#{params[:format]}"
      status(303)                       # HTTP "See Other"
      headers('Location' => redirection)
      # altough the client will move, an entity-body is always returned
      format(
        :path     => '/303',
        :format   => params[:format],
        :objects  => redirection
      )      
    else
      not_found
    end

  end

end
