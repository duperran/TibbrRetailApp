
module Tibbr
  class Link < TibbrResource
    def owner=(value)
      attributes['owner']= value
    end
    def owner
       attributes['owner']
    end

    #attributes =>
    def url
      attributes['url']
    end

    def title
      attributes['title'] 
    end

    def description
      attributes['description']
    end

    def url=(value)
      attributes['url']= value
    end

    def title=(value)
      attributes['title']= value
    end

    def description=(value)
      attributes['description']= value
    end

    def self.fetch_link_details(input_url)
       new(get(:fetch_details, :params => {:url => input_url}))
    end

  end
end