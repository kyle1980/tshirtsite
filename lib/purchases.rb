require 'active_record'

class Purchases < ActiveRecord::Base
  def inventory
    Inventory.where({id: self.shirt_id})
  end
  def customers
    Customers.where({id: self.customer_id})
  end
end
