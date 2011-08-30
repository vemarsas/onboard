require 'facets/hash'
require 'sinatra/base'

require 'onboard/extensions/array'
require 'onboard/pagination'
require 'onboard/service/radius'

class OnBoard
  class Controller < Sinatra::Base

    get '/pub/services/radius/signup.html' do
      conf = Service::RADIUS::Signup.get_config

      if conf['enable'] 
        format(
          :module   => 'radius-admin',
          :path     => '/pub/services/radius/signup',
          :title    => i18n.hotspot.signup,
          :locals   => {
            :conf     => conf, 
            :terms    => Service::RADIUS::Terms::Document.get_all(:asked => true) 
          }
        )
      else
        status 403 # Forbidden
        format(
          :module   => 'radius-admin',
          :path     => '/pub/services/radius/signup_disabled',
          :title    => i18n.hotspot.signup_disabled
        )
      end
    end

    post '/pub/services/radius/signup.html' do
      terms = []
      template_params = {} 
          # in case of auth failure, user doesn't need to re-enter all data 
      config = Service::RADIUS::Signup.get_config
      unless config['enable']
        halt(
          403, # Forbidden
          format(
            :module   => 'radius-admin',
            :path     => '/pub/services/radius/signup_disabled',
            :title    => i18n.hotspot.signup_disabled
          )
        )
      end
      name  = params['check']['User-Name']
      user  = Service::RADIUS::User.new(name) # blank slate
      msg = handle_errors do
        h = config.deep_merge(params)

        # Terms and Conditions acceptance
        terms = Service::RADIUS::Terms::Document.get_all(:asked => true)
        required_terms = terms.select{|h| h[:required]} 
        must_accept = required_terms.map{|h| h[:id]}
        terms_accepted = begin
          params['terms']['accept'].select{|k, v| v == 'on'}.keys.map{|x| x.to_i}
        rescue NoMethodError
          []
        end
        if terms_accepted.include_all_of? must_accept
          # user.accept_terms! terms_accepted 
          #   deferred 'cause we still don't konw the id
        else
          raise Service::RADIUS::Terms::MandatoryDocumentNotAccepted, 'You must accept mandatory Terms and Conditions' 
        end
        Service::RADIUS::User.validate_personal_info(
            :params => params, 
            :fields => config['mandatory']['personal'].select{|k, v| v}.keys
        )

        Service::RADIUS::Check.insert(h)

        user.update_reply_attributes(h) 

        user.update_personal_data(h)
        user.retrieve_personal_info_from_db

        user.accept_terms! terms_accepted
        user.upload_attachments(h) 
      end
      if msg[:ok] and not msg[:err] 
        status 201 # Created
        session[:raduser] = user.name
        session[:radpass] = params['check']['User-Password']
        msg[:info] = %Q{User <a href="users/#{user.name}.html">'#{user.name}'</a> has been created!}
      else
        template_params = params
      end

      format(
        :module   => 'radius-admin',
        :path     => '/pub/services/radius/signup',
        :title    => i18n.hotspot.signup,
        :msg      => msg,
        :locals   => {
          :terms            => terms,
          :conf             => config,
          :template_params  => params
        }
      )

    end
  end
end
