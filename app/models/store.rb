class Store < ActiveRecord::Base
  attr_accessible :city, :country, :latitude, :longitude, :manager, :name, :street, :street_number, :zipcode, :tibbr_id, :tibbr_key, :pictures_attributes
  has_many :pictures
  accepts_nested_attributes_for :pictures, :allow_destroy => true

  
  
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
      Tibbr::ExternalResource.follow({:resource => {:id => self.tibbr_id, :resource_type => "ad:store"}})
    rescue
      nil
    end
  end

  def unfollow
    begin
      Tibbr::ExternalResource.unfollow({:resource => {:id => self.tibbr_id, :resource_type => "ad:store"}, :param => {:id => self.tibbr_id}})
    rescue
      nil
    end
  end
end
