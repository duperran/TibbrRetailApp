module Tibbr
class Channel < TibbrResource
    def update_subject_channel_schedules subject_schedules
      put(:update_subject_channel_schedules, :params => {:subject_schedules => subject_schedules}).instance_of?(Net::HTTPOK)
    end
end
end