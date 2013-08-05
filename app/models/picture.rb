class Picture < ActiveRecord::Base
  attr_accessible :big, :description, :image, :link, :thumb, :title, :item_id, :store_id 

  belongs_to :item, :class_name => "Item", :foreign_key=>'item_id'
  belongs_to :store, :class_name => "Store", :foreign_key => 'store_id'
  accepts_nested_attributes_for :item
  accepts_nested_attributes_for :store

end
