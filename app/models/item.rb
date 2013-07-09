class Item < ActiveRecord::Base
  attr_accessible :name, :reference, :item_type_id
  has_many :pictures
  has_one :item_type
  
end
