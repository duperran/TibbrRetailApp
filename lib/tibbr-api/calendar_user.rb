module Tibbr
  class CalendarUser < TibbrResource
    def status
      attributes['status']
    end
  end
end