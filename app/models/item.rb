class Item < ActiveRecord::Base
  attr_accessible :name, :reference, :item_type_id
  has_many :pictures
  has_one :item_type
  
  def tibbr_resource
    tib_res = nil
    begin
      tib_res = Tibbr::ExternalResource.find self.tibbr_id
    rescue
      nil
    end
    tib_res
  end
  
  def followers
    follow = nil
    begin
      follow = Tibbr::ExternalResource.followers self.tibbr_id
    rescue
      nil
    end

    follow
  end
  
  
  def follow
    begin
      Tibbr::ExternalResource.follow({:resource => {:id => self.tibbr_id, :resource_type => "ad:item"}})
    rescue
      nil
    end
  end

  def unfollow
    begin
      Tibbr::ExternalResource.unfollow({:resource => {:id => self.tibbr_id, :resource_type => "ad:item"}, :param => {:id => self.tibbr_id}})
    rescue
      nil
    end
  end
end

