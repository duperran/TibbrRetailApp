module Tibbr
  class Asset < TibbrResource
    #attributes =>
    #   :data => data file

    def data_file_name
      self.attributes["data_file_name"]
    end

    def size
      self.attributes["data_file_size"]
    end

    def image?
      !(data_content_type.to_s =~ /^image.*/).nil?
    end

    def pdf?
      data_content_type.to_s.include?("application/pdf") || data_content_type.to_s.include?("application/x-pdf")
    end

    def doc?
      data_content_type.to_s.include?("application/msword")
    end

    def txt?
      data_content_type.to_s.include?("text/plain")
    end

    def ppt?
      data_content_type.to_s.include?("application/vnd.ms-powerpoint")
    end
    
    def xls?
      data_content_type.to_s.include?("application/vnd.ms-excel")
    end

    def zip?
      data_content_type.to_s.include?("application/zip")
    end
    
  end
end