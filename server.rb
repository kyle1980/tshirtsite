require 'pry'
require 'sinatra'
require 'sinatra/reloader'
require_relative './lib/connection'
require_relative './lib/purchases'
require_relative './lib/inventory'
require_relative './lib/customers'

shirts_db = SQLite3::Database.new "onelist.db"

after do
  ActiveRecord::Base.connection.close
end

get '/' do
  erb :index, locals: { inventory: Inventory.all() }
end

get '/shirt/:id' do
  id = params[:id]
  selectedShirt = Inventory.find(id)
  erb :show, locals: {shirt: selectedShirt}
end

post '/purchased/:id' do

  id = params[:id]
  email = params["email"]
  quantity = params["quantity"]
  # userCheck = shirts_db.execute("SELECT 1 FROM customers WHERE email = ?", params["email"].length > 0)

  idCheck = Customers.find_by({email: email})
  if idCheck == nil
    customer_hash = {
      name: params["name"],
      email: params["email"]
    }

    Customers.create(customer_hash);

    findCustomer = Customers.find_by({email: email})

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
    customerInfo = Customers.find_by(currentPurchase.customer_id)

    erb :confirmation, locals: {purchaseInfo: currentPurchase, shirtInfo: shirtInfo, customerInfo: customerInfo}

  elsif idCheck != nil
    findCustomer = Customers.find_by({email: email})

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
    customerInfo = Customers.find_by(currentPurchase.customer_id)

    erb :confirmation, locals: {purchaseInfo: currentPurchase, shirtInfo: shirtInfo, customerInfo: customerInfo}
  end
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
