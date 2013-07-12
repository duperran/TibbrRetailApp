module Tibbr
  class ExternalResource < TibbrResource
    #include Tibbr::ExternalResourceExtension
    self.element_name = "resource"
    #self.include_root_in_json = false

    def self.get_by_url url, attr={}
      get(:get_by_url, {:resource_url => url})
    end

    def self.find_by_resource_key options
      begin
        res = get(:find_by_resource_key, options)
        #return nil unless res.instance_of?(Net::HTTPOK)
        Resource.new(res)
      rescue ActiveResource::ResourceInvalid => error
        ExternalResource.new.tap{|u| u.populate_error(error)}
      end
    end

    def self.follow options
      res = post(:follow, options)
    end

    def self.unfollow options
      res = delete(:unfollow, options)
    end

    def self.followers resource_id
      begin
        res = get(:followers, {:resource => {:id => resource_id}, :per_page=>5000000})
        #return nil unless res.instance_of?(Net::HTTPOK)
        Resource.new(res)
      rescue ActiveResource::ResourceInvalid => error
        ExternalResource.new.tap{|u| u.populate_error(error)}
      end
    end

    def self.add_followers options
      post(:add_followers, options)
    end

    def self.remove_followers options
      delete(:remove_followers, options)
    end

    def self.batch_add_followers options
      post(:batch_add_followers, options)
    end

    def self.get_or_create_by_url url, attr={}
      begin
           res = post(:get_by_url, {:resource_url => url})
           return nil unless res.instance_of?(Net::HTTPOK)
           ExternalResource.new(format.decode(res.body))
         rescue ActiveResource::ResourceInvalid => error
           ExternalResource.new.tap{|u| u.populate_error(error)}
         end
    end

    def self.get_or_create_by_resource_key key, attrs={}
      begin
        res = get(:get_by_resource_key, {:resource_key => key})
        return ExternalResource.new({:resource_key => key}.merge(attrs)) unless res.instance_of?(Net::HTTPOK)
        ExternalResource.new(format.decode(res.body))
      rescue ActiveResource::ResourceInvalid => error
        ExternalResource.new.tap{|u| u.populate_error(error)}
      end
    end


  end

end