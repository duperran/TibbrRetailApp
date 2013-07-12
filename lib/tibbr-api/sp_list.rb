module Tibbr

  class SpList < TibbrResource
    EMPTY_SHAREPOINT_CREDETIALS = "EMPTY_SHAREPOINT_CREDETIALS"
    INCORRECT_SHAREPOINT_CREDETIALS = "INCORRECT_SHAREPOINT_CREDETIALS"

    def self.lists *args
      options = args.extract_options!
      payload = options.blank? ? nil : options.to_xml(:root => 'params').to_s
      res = post(:lists, {}, payload)
      TibbrResource.paginate_collection(format.decode(res.body), SpList)
    rescue ActiveResource::ResourceInvalid => error
      SpList.new.tap { |u| u.populate_error(error) }
    end

    def self.search *args
      options = args.extract_options!
      TibbrResource.paginate_collection(get(:search, :params => options), SpItem)
    rescue ActiveResource::ResourceInvalid => error
      SpItem.new.tap { |u| u.populate_error(error) }
    end


    def self.list_items *args
      options = args.extract_options!
      TibbrResource.paginate_collection(get(:list_items, :params => options), SpItem)
    rescue ActiveResource::ResourceInvalid => error
      SpItem.new.tap { |u| u.populate_error(error) }
    end

    def self.sites *args
      options = args.extract_options!
      payload = options.blank? ? nil : options.to_xml(:root => 'params').to_s
      res = post(:sites, {}, payload)
      TibbrResource.paginate_collection(format.decode(res.body), SpSite)
    rescue ActiveResource::ResourceInvalid => error
      SpSite.new.tap { |u| u.populate_error(error) }
    end

    def save
      multipart_send(update_url, :put)
    end

  end
end