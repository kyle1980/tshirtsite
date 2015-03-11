require 'active_record'

class Purchase < ActiveRecord::Base
  belongs_to :inventory
  belongs_to :customer
  # def inventory
  #   Inventory.where({id: self.shirt_id})
  # end
end
