class Picture < ActiveRecord::Base
  attr_accessible :big, :description, :image, :link, :thumb, :title, :item_id
  belongs_to :item
  
end
