module Tibbr
  class Calendar < TibbrResource
    def owner=(value)
      attributes['owner']= value
    end
    def owner
      attributes['owner']
    end

    #attributes =>
    def start_date_time
      attributes['start_date_time']
    end

    def location
      attributes['location']
    end

    def duration
      attributes['duration']
    end

    def start_date_time=(value)
      attributes['start_date_time']= value
    end

    def location=(value)
      attributes['location']= value
    end

    def duration=(value)
      attributes['duration']= value
    end

    def self.fetch_calendars_by_subject(subject_name)
      new(get(:fetch_calendar_by_subject, :params => {:subject => subject_name}))
    end

    def user_responses(options = {})
      get(:user_responses,:params => {:status => options[:status]})
    end

    def current_user_response
      get(:current_user_response)
    end

    def create_rsvp(options = {})
      put(:create_rsvp,:params => {:status => options[:status]})
    end

    def self.upcoming_events_for_user(options = {})
      get(:upcoming_events_for_user,:params => {:user => options[:user],:page => options[:page],:per_page => options[:per_page]})
    end

    def self.upcoming_events_for_subject(options = {})
      get(:upcoming_events_for_subject,:params => {:subject => options[:subject],:page => options[:page],:per_page => options[:per_page]})
    end

    def is_user_responded
      begin
        get(:is_user_responded)
      rescue Exception => msg
        return []
      end
    end
  end
end