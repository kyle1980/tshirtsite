require 'active_record'

<<<<<<< HEAD
class Purchases < ActiveRecord::Base

  def items
    item.where({id: self.shirt_id})
  end
  def customers
    Customers.where({id: self.customer_id})
  end

  belongs_to :inventory
  belongs_to :customer

=======
class Purchase < ActiveRecord::Base
  belongs_to :inventory
  belongs_to :customer
  # def inventory
  #   Inventory.where({id: self.shirt_id})
  # end
>>>>>>> f96a04a7efb166fff88c0ed35acdc0b4f539040f
end
