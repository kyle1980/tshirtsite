require 'sinatra'
require 'sinatra/reloader'
require_relative './lib/connection'
require_relative './lib/purchases'

after do
  ActiveRecord::Base.connection.close
end

get '/' do
  erb :index, locals: { inventory: Inventory.all() } 
end
