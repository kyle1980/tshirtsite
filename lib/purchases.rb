require 'active_record'

class Purchases < ActiveRecord::Base

  def items
    item.where({id: self.shirt_id})
  end
  def customers
    Customers.where({id: self.customer_id})
  end

  belongs_to :inventory
  belongs_to :customer

end
