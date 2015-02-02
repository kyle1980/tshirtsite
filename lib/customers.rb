require 'active_record'

class Customers < ActiveRecord::Base
  has_many :purchases
end
