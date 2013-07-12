module Tibbr
  class ExternalResourceAction < TibbrResource
    self.element_name = "actions"
    #self.include_root_in_json = false

    def self.publish options
      res = post(:publish, options)
      return nil unless res.instance_of?(Net::HTTPOK)
      ExternalResource.new(format.decode(res.body))
    end
  end

end