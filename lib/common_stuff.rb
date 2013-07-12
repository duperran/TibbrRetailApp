 module CommonStuff
  def isfollowingstore? res
    followers = res.followers
    return false if followers.nil?
    followers.items.each do |f|

      return true if f.id == @current_user.id
    end

    return false
   
  end
end