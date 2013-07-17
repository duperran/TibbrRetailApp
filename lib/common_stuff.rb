 module CommonStuff
  def isfollowingstore? res
    
   
    @store = Store.find(res.id)
    followers = @store.followers

    return false if followers.nil?
    followers.items.each do |f|
      return true if f.id == @current_user.id
    end

    return false
   
  end
  
  def isfollowingitem? res
    
     @item = Item.find(res.id)
    followers = @item.followers
    
    followers = res.followers
    return false if followers.nil?
    followers.items.each do |f|
      return true if f.id == @current_user.id
    end

    return false
    
    
  end
end