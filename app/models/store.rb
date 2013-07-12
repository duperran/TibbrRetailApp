class Store < ActiveRecord::Base
  attr_accessible :city, :country, :latitude, :longitude, :manager, :name, :street, :street_number, :zipcode, :tibbr_id
  
  
  
  def tibbr_resource
    tib_res = nil
    begin
      tib_res = Tibbr::ExternalResource.find "ID_#{self.id}"
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
      Tibbr::ExternalResource.follow({:login => @current_user.id ,:resource => {:id => self.tibbr_id, :resource_type => "ad:store"}})
    rescue
      nil
    end
  end

  def unfollow
    begin
      Tibbr::ExternalResource.unfollow({:resource => {:id => "ID_#{self.id}", :resource_type => "ad:store"}, :param => {:id => "ID_#{self.id}"}})
    rescue
      nil
    end
  end
end
