class Picture < ActiveRecord::Base
  attr_accessible :big, :description, :image, :link, :thumb, :title

  belongs_to :item
  accepts_nested_attributes_for :item
  
end
