require 'pry'
require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'bcrypt'
require_relative './lib/connection'
require_relative './lib/purchases'
require_relative './lib/inventory'
require_relative './lib/customer'

shirts_db = SQLite3::Database.new "shirts.db"

use Rack::Session::Pool, :cookie_only => false

def authenticated?
  session[:valid_user]
end

after do
  ActiveRecord::Base.connection.close
end

get '/' do
  if session[:valid_user] == true
    erb :index, locals: { inventory: Inventory.all() }
  else
    erb :signup
  end
end

get '/loginPage' do
  erb :login
end

post '/login' do
  username = params["username"]
  password = params["password"]
  userCheck = Customer.find_by({name: username})
  puts userCheck

  if userCheck != nil
    if BCrypt::Password.new(userCheck.password) == params["password"]
      session[:valid_user] = true
      session[:username] = username
      puts session[:username]
      session[:cart] = []
    end
  end

  redirect '/'
end

get '/signUpPage' do
  erb :signup
end

post '/signup' do
  username = params["username"]
  password = params["password"]
  confirmPassword = params["confirm_password"]
  email = params["email"]
  fullName = params["fullName"]
  phone = params["phone"]
  address = params["address"]
  city = params["city"]
  state = params["state"]
  zip = params["zip"]

  if password == confirmPassword
    my_password = BCrypt::Password.create(params["password"])
    puts my_password
    customer_hash = {
        name: username,
        password: my_password,
        email: email,
        fullName: fullName,
        phone: phone,
        address: address,
        city: city,
        state: state,
        zip: zip
      }
    Customer.create(customer_hash);
    session[:valid_user] = true
    session[:username] = username
    session[:cart] = []
    redirect '/'
  else
    redirect 'login'
  end
end

get '/shirt/:id' do
  id = params[:id]
  selectedShirt = Inventory.find(id)
  erb :show, locals: {shirt: selectedShirt}
end

post '/addToCart/:id' do
  shirt_id = params[:id]
  quantity = params["quantity"]
  username = session[:username]
  selectedShirt = Inventory.find(shirt_id)
  customer = Customer.find_by({name: username})
  cartHash = {shirt_id: shirt_id, item: selectedShirt.item, price: selectedShirt.price, quantity: quantity, customer_id: customer.id}
  cart = session[:cart]
  cart.push(cartHash)
  redirect '/'
end

post '/checkout' do
  cart = session[:cart]
  erb :cart, locals: {cart: cart}
end

get '/deleteCartItem/:id' do
  index = params[:id]
  cart = session[:cart]
  cart.delete_at(index.to_i)
  erb :cart
end

get '/clearCart' do
  session[:cart].clear
  redirect '/'
end



post '/purchase' do
  username = session[:username]
  customer_id = Customer.find_by({name: username})
  cart = session[:cart]
  cart.each do |hash|
    purchase_hash ={
      shirt_id: hash[:shirt_id],
      quantity: hash[:quantity],
      customer_id: hash[:customer_id]
    }
    Purchase.create(purchase_hash)
    findShirtData = Inventory.find_by({id: hash[:shirt_id]})
    newQuantity = Integer(findShirtData.quantity) - Integer(hash[:quantity])
    inventory_hash = {
        item: findShirtData.item,
        price: Integer(findShirtData.price),
        quantity: Integer(newQuantity),
        url: findShirtData.url
      }
    findShirtData.update(inventory_hash)
  end

  erb :confirmation
end

get '/admin' do
  erb :admin, locals: {purchases: Purchase.all(), inventory: Inventory.all()}
end

post '/update/:id' do
  id = params[:id]
  quantity = params["quantity"]

  findShirtData = Inventory.find_by({id: id})

  newQuantity = Integer(findShirtData.quantity) + Integer(quantity)

  inventory_hash = {
    item: findShirtData.item,
    price: Integer(findShirtData.price),
    quantity: Integer(newQuantity),
    url: findShirtData.url
  }

  findShirtData.update(inventory_hash)

  redirect '/admin'
end

post '/delete/:id' do
  id = params[:id]
  Inventory.delete(id)

  redirect '/admin'
end

post '/createItem' do
  item = params["item"]
  price = params["price"]
  quantity = params["quantity"]
  url = params["url"]
  inventory_hash = {
    item: item,
    price: price,
    quantity: quantity,
    url: url
  }
  Inventory.create(inventory_hash)
  redirect '/admin'
end

get '/orders' do
  username = session[:username]
  customer = Customer.find_by({name: username})

  orders = customer.purchases

  puts orders
  erb :orders, locals: {orders: orders }
end

get '/myAccount' do
  username = session[:username]
  info = Customer.find_by({name: username})
  purchases = info.purchases
  erb :myAccount, locals: {info: info, purchases: purchases}
end

get '/logout' do
  session[:valid_user] = false
  redirect '/'
end
