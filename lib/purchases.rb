require 'active_record'

class Purchases < ActiveRecord::Base
<<<<<<< HEAD
  def items
    item.where({id: self.shirt_id})
  end
  def customers
    Customers.where({id: self.customer_id})
  end
=======
  belongs_to :inventory
  belongs_to :customer
  # def inventory
  #   Inventory.where({id: self.shirt_id})
  # end
  # def customers
  #   Customers.where({id: self.customer_id})
  # end
>>>>>>> cfef8e11d5f7669405de3d3f2fdc2627e1165c36
end
