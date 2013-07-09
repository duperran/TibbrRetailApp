class CollectionItemsAssoc < ActiveRecord::Base
   attr_accessible :collection_id, :item_id
   belongs_to :item
   belongs_to :collection
end
