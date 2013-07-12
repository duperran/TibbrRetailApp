
module Tibbr
  class QuestionOption < TibbrResource
    #attributes =>
    def option_label
      attributes['option_label']
    end

    def position
      attributes['position']
    end

    def option_label=(value)
      attributes['option_label']=value
    end

    def position=(value)
      attributes['position']=value
    end

  end
end