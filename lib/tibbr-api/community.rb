module Tibbr

  class Community < TibbrResource
    
    def self.find(*args)
      opts = args.extract_options!
      opts[:params] ||= {}
      opts[:params][:params] ||= {}
      opts[:params][:params][:set_actions] ||= "true"
      args << opts
      super
    end

    def self.all(options = {})
      find(:all, :params => (options || {}).slice(:include_deleted))
    end
    
    def creator
       @creator = self.attributes["user"] || nil
    end

    def delete
      load_from_response(put(:delete))
    end
    
    def undelete
      load_from_response(put(:undelete))
    end

  end

end