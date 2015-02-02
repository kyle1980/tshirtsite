require 'sinatra'
require 'sinatra/reloader'
require_relative './lib/connection'
require_relative './lib/purchases'
require_relative './lib/items'

after do
  ActiveRecord::Base.connection.close
end

get '/' do
  erb :index, locals: { inventory: items.all() }
end
