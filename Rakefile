require 'dotenv'
Dotenv.load

require 'sinatra/activerecord'
require 'sinatra/activerecord/rake'

namespace :db do
  task :load_config do
    require_relative './app'
  end
end
