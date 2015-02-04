require 'pry'
require 'sinatra'
require 'sinatra/reloader'
<<<<<<< HEAD
require 'sinatra/cross_origin'

configure do
  enable :cross_origin
end

=======
require 'json'
require 'bcrypt'
>>>>>>> f96a04a7efb166fff88c0ed35acdc0b4f539040f
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

<<<<<<< HEAD
post '/purchased/:id' do
  puts "purchase attempt"

  id = params[:id]
  buy_data = JSON.parse(request.body.read)

  email = buy_data["email"]
  quantity = buy_data["quantity"]
  name = buy_data["name"]
  puts buy_data

  # userCheck = shirts_db.execute("SELECT 1 FROM customers WHERE email = ?", email.length > 0)

  idCheck = Customers.find_by({email: email})

  if idCheck == nil
    customer_hash = {
      name: buy_data["name"],
      email: buy_data["email"]
    }

    Customers.create(customer_hash);

    findCustomer = Customers.find_by({email: email})

    purchase_hash ={
      shirt_id: id,
      quantity: buy_data["quantity"],
      customer_id: findCustomer.id
    }
    Purchases.create(purchase_hash)
=======
  redirect '/'
end

post '/signup' do
  username = params["username"]
  password = params["password"]
  confirmPassword = params["confirm_password"]
  email = params["email"]

  if password == confirmPassword
    my_password = BCrypt::Password.create(params["password"])
    puts my_password
    customer_hash = {
        name: username,
        password: my_password,
        email: email
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
>>>>>>> f96a04a7efb166fff88c0ed35acdc0b4f539040f

get '/shirt/:id' do
  id = params[:id]
  selectedShirt = Inventory.find(id)
  erb :show, locals: {shirt: selectedShirt}
end

post '/addToCart/:id' do
  shirt_id = params[:id]
  quantity = params["quantity"]
  selectedShirt = Inventory.find(shirt_id)
  cartHash = {shirt_id: shirt_id, item: selectedShirt.item, price: selectedShirt.price, quantity: quantity}
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

<<<<<<< HEAD
    # currentPurchase = Purchases.last()
    # shirtInfo = Inventory.find_by(currentPurchase.shirt_id)
    # customerInfo = Customers.find_by(currentPurchase.customer_id)

    # erb :confirmation, locals: {purchaseInfo: currentPurchase, shirtInfo: shirtInfo, customerInfo: customerInfo}
=======
get '/clearCart' do
  session[:cart].clear
  redirect '/'
end

>>>>>>> f96a04a7efb166fff88c0ed35acdc0b4f539040f


post '/purchase' do
  username = session[:username]
  customer_id = Customer.find_by({name: username})
  cart = session[:cart]
  cart.each do |hash|
    purchase_hash ={
<<<<<<< HEAD
      shirt_id: id,
      quantity: buy_data["quantity"],
      customer_id: findCustomer.id
=======
      shirt_id: hash[:shirt_id],
      quantity: hash[:quantity],
      customer_id: customer_id
>>>>>>> f96a04a7efb166fff88c0ed35acdc0b4f539040f
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
<<<<<<< HEAD

    currentPurchase = Purchases.last()
    shirtInfo = Inventory.find_by(currentPurchase.shirt_id)
    customerInfo = Customers.find_by(currentPurchase.customer_id)

    # erb :confirmation, locals: {purchaseInfo: currentPurchase, shirtInfo: shirtInfo, customerInfo: customerInfo}


    currentPurchase = Purchases.last()
    shirtInfo = Inventory.find_by(currentPurchase.shirt_id)
    customerInfo = Customers.find_by(currentPurchase.customer_id)
    # puts currentPurchase
    # puts shirtInfo
    # puts currentInfo
    erb :confirmation, locals: {purchaseInfo: currentPurchase, shirtInfo: shirtInfo, customerInfo: customerInfo}
=======
>>>>>>> f96a04a7efb166fff88c0ed35acdc0b4f539040f
  end

  erb :confirmation
end


  # id = params[:id]
  # username = session[:username]
  # quantity = params["quantity"]
  #
  #   findCustomer = Customer.find_by({name: username })
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
  #   customerInfo = Customer.find_by(currentPurchase.customer_id)
  #
  #   erb :confirmation, locals: {purchaseInfo: currentPurchase, shirtInfo: shirtInfo, customerInfo: customerInfo}
# end

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

<<<<<<< HEAD
# get '/purchase' do
#   puts "purchase confirm attempt"
#   currentPurchase = Purchases.last()
#   shirtInfo = Inventory.find_by(currentPurchase.shirt_id)
#   customerInfo = Customers.find_by(currentPurchase.customer_id)
#   # puts currentPurchase
#   # puts shirtInfo
#   # puts currentInfo
#   erb :confirmation, locals: {purchaseInfo: currentPurchase, shirtInfo: shirtInfo, customerInfo: customerInfo}
#
# end
=======
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
>>>>>>> f96a04a7efb166fff88c0ed35acdc0b4f539040f
