require 'pry'
require 'sinatra'
require 'sinatra/reloader'
require 'json'
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
    erb :auth
  end
end

get '/login' do
  username = params["username"]
  password = params["password"]
  userCheck = Customer.find_by({name: username, password: password})
  if userCheck != nil
    session[:valid_user] = true
    session[:username] = username
    puts session[:username]
    redirect '/'
  elsif userCheck == nil
    redirect '/login'
  end
end

post '/signup' do
  username = params["username"]
  password = params["password"]
  confirmPassword = params["confirm_password"]
  email = params["email"]

  if password == confirmPassword
    customer_hash = {
        name: username,
        password: password,
        email: email
      }
    Customer.create(customer_hash);
    session[:valid_user] = true
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

post '/purchased/:id' do

  id = params[:id]
  username = session[:username]
  quantity = params["quantity"]
  # userCheck = shirts_db.execute("SELECT 1 FROM customers WHERE email = ?", params["email"].length > 0)

  # idCheck = Customers.find_by({email: email})
  # if idCheck == nil
  #   customer_hash = {
  #     name: params["name"],
  #     password: params
  #     email: params["email"]
  #   }
  #
  #   Customers.create(customer_hash);

    findCustomer = Customer.find_by({name: username })

    purchase_hash ={
      shirt_id: id,
      quantity: params["quantity"],
      customer_id: findCustomer.id
    }
    Purchases.create(purchase_hash)

    findShirtData = Inventory.find_by({id: id})

    newQuantity = Integer(findShirtData.quantity) - Integer(quantity)

    inventory_hash = {
      item: findShirtData.item,
      price: Integer(findShirtData.price),
      quantity: Integer(newQuantity),
      url: findShirtData.url
    }

    findShirtData.update(inventory_hash)

    currentPurchase = Purchases.last()
    shirtInfo = Inventory.find_by(currentPurchase.shirt_id)
    customerInfo = Customer.find_by(currentPurchase.customer_id)

    erb :confirmation, locals: {purchaseInfo: currentPurchase, shirtInfo: shirtInfo, customerInfo: customerInfo}

  # elsif idCheck != nil
  #   findCustomer = Customers.find_by({email: email})
  #
  #   purchase_hash ={
  #     shirt_id: id,
  #     quantity: params["quantity"],
  #     customer_id: findCustomer.id
  #   }
  #   Purchases.create(purchase_hash)
  #
  #   findShirtData = Inventory.find_by({id: id})
  #
  #   newQuantity = Integer(findShirtData.quantity) - Integer(quantity)
  #
  #   inventory_hash = {
  #     item: findShirtData.item,
  #     price: Integer(findShirtData.price),
  #     quantity: Integer(newQuantity),
  #     url: findShirtData.url
  #   }
  #
  #   findShirtData.update(inventory_hash)
  #
  #   currentPurchase = Purchases.last()
  #   shirtInfo = Inventory.find_by(currentPurchase.shirt_id)
  #   customerInfo = Customers.find_by(currentPurchase.customer_id)
  #
  #   erb :confirmation, locals: {purchaseInfo: currentPurchase, shirtInfo: shirtInfo, customerInfo: customerInfo}
  # end
end

get '/admin' do
  erb :admin, locals: {purchases: Purchases.all(), inventory: Inventory.all()}
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

get '/logout' do
  session[:valid_user] = false
  redirect '/'
end
