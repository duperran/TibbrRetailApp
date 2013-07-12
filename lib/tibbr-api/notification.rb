module Tibbr
  class Notification < TibbrResource

   class << self
       def generate_notifications app_id=nil, notifications=[]
         raise ActiveResource::BadRequest if !app_id || notifications.empty?
         res = post("generate", {:app_id => app_id, :notifications => notifications})
         res.instance_of?(Net::HTTPOK)  ? true : res
       end

       def short_ref obj, caption=nil
         ShortRef.new obj, caption
       end
     
   end

  end

 class ShortRef
    @short_ref_string = ""
    def initialize obj, caption = nil
      if obj.class == String
        @short_ref_string = obj
      else
        class_name = obj.class.name
        class_name = obj.class.name.gsub(/^Tibbr::/,"") if class_name.starts_with?("Tibbr::")
        @short_ref_string = "@[#{class_name}:#{obj.id}|"
        @short_ref_string << "#{obj.send(caption)}" if  caption
        @short_ref_string << "]"
      end
    end

    def to_xml
      @short_ref_string
    end

    def to_s
      @short_ref_string
    end

    def to_json
      @short_ref_string
    end
  end

 module NotificationRef
    def to_notification_str caption=nil
      ShortRef.new(self,caption)
    end
 end
  
 end

# include to_notification_obj method to all Tibbr::ResourceObject
class Tibbr::TibbrResource
  include Tibbr::NotificationRef
end