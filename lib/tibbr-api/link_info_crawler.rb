require "rubygems"
require 'net/http'
require 'nokogiri'
module Tibbr
  class LinkInfoCrawler
    attr_reader :html_doc
    $YOUTUBE_URL_REGEX = /http:\/\/www.youtube.com\/watch\?.*v=([^(&|#)]*)/
    $YOUTUBE_API_URL = "http://gdata.youtube.com/feeds/api/videos/"

    def self.allowed_responses
      [Net::HTTPOK, Net::HTTPAccepted, Net::HTTPPartialContent, Net::HTTPNonAuthoritativeInformation, Net::HTTPNoContent, Net::HTTPResetContent, Net::HTTPPartialContent]
    end

    def initialize(url_path, redirection_attempts=2)
      url_path = URI.escape(url_path.to_s) if(URI.unescape(url_path.to_s) == url_path.to_s)
      url_path = url_path.gsub("%23","#") # Resolved: TIBR-TIBR-9295 Hack to retain the # values in the URL.
      (url_path =~ $YOUTUBE_URL_REGEX)
      url_value= $1.nil? ? (url_path):($YOUTUBE_API_URL + $1)
      @unique_id = $1
      @youtube_link = true unless $1.nil?
      res= self.class.url_to_html_doc(url_value)
      current_attempt=0
      while(res.response['Location']!=nil && redirection_attempts > current_attempt)
        res= self.class.url_to_html_doc(res.response['Location'])
        current_attempt+=1
      end
      res= LinkInfoCrawler.allowed_responses.include?(res.class) ? res : nil
      @url_path = url_path
      @html_doc= Nokogiri::HTML(res.body) if res.body
    end

    def title
      @html_doc.xpath("//title")[0].text rescue ""
    end

    def description
      return youtube_description if youtube_link?
      description_text = ""
      posts = @html_doc.xpath("//meta")

      posts.each do |link|
        unless link.attributes['name'].nil?
          if link.attributes['name'].value == "Description" || link.attributes['name'].value == "description"
            description_text = link.attributes['content'].value
          end
        end
      end
      description_text
    end

    def preview_image
      youtube_link? ? youtube_image_preview : non_youtube_image_preview
    end

    def non_youtube_image_preview
      image_urls = @html_doc.xpath("//img").collect{|k| k.attributes["src"]} rescue []
      image_urls = image_urls.map{|k| k.value} unless image_urls.blank?
      image_url = image_urls.blank? ? nil : ((image_urls.select{|k| k.include?("http://")||k.include?("https://")}).first || image_urls.first)
      #image_url = @html_doc.xpath("//img").first.attributes["src"].value rescue nil
      return nil if image_url.blank?
      image_uri = URI.parse(image_url)
      return image_url if image_uri.host.present?
      url = URI.parse(@url_path)
      img_url = (url.path.blank? || url.path == "/") ? ("#{@url_path}/#{image_url}".gsub(/\/+/, '/').gsub(":/", "://")) : (@url_path.gsub(url.path, image_url))
      prev_url = URI.parse(img_url) rescue nil
      (prev_url.present? && prev_url.host.present?) ? img_url : nil
    end

    def youtube_image_preview
      "http://i3.ytimg.com/vi/#{@unique_id}/default.jpg"
    end

    def youtube_link?
      @youtube_link
    end

    def youtube_description
      @html_doc.xpath("//content").text
    end

    class << self
      def title(url)
        link_crawler= new(url)
        link_crawler.title
      end

      def description(url)
        link_crawler= new(url)
        link_crawler.description
      end

      def url_to_html_doc(url_path)
        Rails.logger.info "Crawling link: #{url_path}"
        url = URI.parse(url_path)
        url.path= '/' if url.path.empty?
        req = Net::HTTP::Get.new(url.path, {"User-Agent" => "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.9.2.10) Gecko/20100914 Firefox/3.6.10 ( .NET CLR 3.5.30729)"})
        http = Net::HTTP.new(url.host, url.port)
        http.open_timeout = 5
        http.read_timeout = 10
        http.use_ssl = url.scheme == 'https'
        res= http.start {|http| http.request(req)}
        res
      end
    end
  end
end