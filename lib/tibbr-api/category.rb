module Tibbr
  class Category < TibbrResource
    
    def self.all(options = {})
      find(:all, :params => (options || {}))
    end
    
  end
end