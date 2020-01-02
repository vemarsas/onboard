MODULESDIR = File.dirname(__FILE__) + '/modules'

source "https://rubygems.org" do

  # A few of the below are currently only required by certain modules.
  # However, they are of general use (and perhaps not too heavyweight)
  # and may be required by the core as well at some point.
  gem 'hierarchical_menu'
  gem 'sinatra', '~> 2'
  gem 'rack-contrib', '~> 2'
  gem 'thin'
  gem 'locale'
  gem 'i18n_data'
  gem 'sinatra-r18n', '~> 2'  # TODO: v3? compat. issues?
  gem 'erubis'
  gem 'uuid'
  gem 'facets'
  gem 'archive-tar-minitar'
  gem 'rubyzip', '~> 1'
  gem 'cronedit'
  gem 'chronic_duration'
  gem 'mail'
  gem 'escape'

  group :test, :development do
    gem 'rspec', '~> 3.8'
    gem 'rack-test', '~> 0.6.3'
    gem 'json_spec', '~> 1.1', '>= 1.1.5'
  end

  # Modules
  Dir.foreach(MODULESDIR) do |mod|
    next if ['..', '.'].include? mod
    gemfile = "#{MODULESDIR}/#{mod}/Gemfile"
    if File.exists? gemfile
      group mod.to_sym do
        eval_gemfile gemfile
      end
    end
  end

end
