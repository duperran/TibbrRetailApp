class Collection < ActiveRecord::Base
  attr_accessible :name, :season, :year
    has_many :collection_items_assocs
    has_many :items, :through => :collection_items_assocs

end
