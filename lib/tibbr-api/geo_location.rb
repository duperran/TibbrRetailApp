
module Tibbr
  class GeoLocation < TibbrResource
    #attributes =>
    def latitude
      attributes['latitude']
    end

    def longitude
      attributes['longitude']
    end

    def place
      attributes['place']
    end

    def latitude=(value)
      attributes['latitude']= value
    end

    def longitude=(value)
      attributes['longitude']= value
    end

    def place=(value)
      attributes['place']= value
    end
  end
end