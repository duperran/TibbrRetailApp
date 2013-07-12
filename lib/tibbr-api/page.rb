module Tibbr
  class Page < TibbrResource
    def self.all(options = {})
      find(:all, :params => (options || {}))
    end

    def add_language(options = {})
      load_from_response(put(:add_language, :params => options))
    end

    def update_language(options = {})

      #      load_from_response(put(:update_language, :params => options))
      put(:update_language, :params => options)
    end

    def delete_language(options = {})
      load_from_response(put(:delete_language, :params => options))
    end

    def self.create_with_languages(options ={})
      begin
        res = post(:create_with_languages, :page => options)
        return nil unless res.instance_of?(Net::HTTPOK)
        Page.new(format.decode(res.body))
      rescue ActiveResource::ResourceInvalid => error
        Page.new.tap{|u| u.populate_error(error)}
      end
    end
    
    def update_with_languages(options ={})
      put(:update_with_languages, :params => options)
    end
    
  end
end