# Monkey patch to address the error handling bug in Rails 2.3.4
require 'ostruct'
class Object
  def hash2object(object)
    return case object
    when Hash
      object = object.clone
      object.each do |key, value|
        object[key] = hash2object(value)
      end
      OpenStruct.new(object)
    when Array
      object = object.clone
      object.map! { |i| hash2object(i) }
    else
      object
    end
  end
end

class ActiveResource::Base
  cattr_accessor :client_key

  class << self

    def auth_token=(a_token)
      Thread.current[:auth_token] = a_token
    end

    def tenant_name=(t_name)
      Thread.current[:tenant_name] = t_name
    end

    def host=(host_name)
      Thread.current[:host] = host_name
    end

    def auth_token
      Thread.current[:auth_token]
    end

    def client_id=(client_id)
      Thread.current[:client_id] = client_id
    end

    def client_id
      Thread.current[:client_id]
    end

    def client_secret=(client_secret)
      Thread.current[:client_secret] = client_secret
    end

    def client_secret
      Thread.current[:client_secret]
    end

    def access_token=(access_token)
      Thread.current[:access_token] = access_token
    end

    def access_token
      Thread.current[:access_token]
    end
    
    def host
      Thread.current[:host]
    end

    def tenant_name
      Thread.current[:tenant_name]
    end

    def user_agent=(ua)
      Thread.current[:user_agent]=ua
    end

    def user_agent
      Thread.current[:user_agent]
    end

    def remember_token=(r_token)
      Thread.current[:remember_token] = r_token
    end

    def remember_token
      Thread.current[:remember_token]
    end

    def http_accept_language
      Thread.current[:http_accept_language]
    end 

     def http_accept_language=(browser_language_string)
      Thread.current[:http_accept_language] = browser_language_string
    end

     #Usage: impersonate_param=(['user_id',5])
     #       impersonate_param=(['impersonate_user_id',5])
     #       impersonate_param=(['user_email','tom@tibbr.com'])
     def impersonate_param=(param_name_and_value=[])
       return (Thread.current[:impersonate_param] = nil) unless(param_name_and_value.is_a?(Array) and param_name_and_value.size == 2)
       param_name_and_value[0] = (param_name_and_value[0].to_s.starts_with?('impersonate_') ? param_name_and_value.to_s : "impersonate_#{param_name_and_value[0]}")
       Thread.current[:impersonate_param] = param_name_and_value.join(',')
     end

     # Returns nil or array E.g. ['impersonate_user_email','tom@tibbr.com']
     def impersonate_param
       Thread.current[:impersonate_param].try(:split,',')
     end

    def headers
     ((superclass.respond_to?(:headers) and superclass.headers) or {}).tap do |headers|
        headers['client_key']= client_key unless client_key.blank?
        headers['auth_token']= auth_token unless auth_token.blank?
        headers['remember_token'] = remember_token unless remember_token.blank?
        headers['HTTP_ACCEPT_LANGUAGE'] = http_accept_language unless http_accept_language.blank?
        headers[impersonate_param[0]] = impersonate_param[1] unless impersonate_param.blank?
        headers['tenant_name']= Thread.current[:tenant_name] if Thread.current[:tenant_name]
        headers['Host'] = host if host
        headers['User-Agent'] = user_agent if user_agent
        headers['access_token']= access_token unless access_token.blank?
        headers['client_id']= client_id unless client_id.blank?
        headers['client_secret']= client_secret unless client_secret.blank?
     end
    end
  end

  def save
    save_without_validation
    true
  rescue ActiveResource::ResourceInvalid => error
    case error.response['Content-Type']
      when /application\/xml/
      errors.from_xml(error.response.body)
      when /application\/json/
      errors.from_json(error.response.body)
    end
    false
  end

  def to_json(options={})
    super(self.include_root_in_json ? { :root => self.class.element_name }.merge(options) : options)
  end

end

module Tibbr

  module ActiveResourceExtension
    # NOTE: Please contact Darshan or Madhav before changing tibbr_response_class or tibbr_response_code
    attr_accessor :tibbr_response_class, :tibbr_response_code
    def populate_error(error)
      Rails.logger.error "error in populate error: #{error.message}" if error.respond_to? :message
      @tibbr_response_class = error.response.class
      @tibbr_response_code = error.response.code
      case error.response['Content-Type']
        when /application\/xml/
        errors.from_xml(error.response.body)
        when /application\/json/
        errors.from_json(error.response.body)
      end
    end

    def get(method_name, options = {})
      super
    rescue ActiveResource::ConnectionError => error
      populate_error(error)
      nil
    end

    def post(method_name, options = {}, body = nil)
      super
    rescue ActiveResource::ConnectionError => error
      populate_error(error)
      false
    end

    def put(method_name, options = {}, body = '')
      super
    rescue ActiveResource::ConnectionError => error
      populate_error(error)
      false
    end
  end

  class TibbrResource < ActiveResource::Base

    include Tibbr::ActiveResourceExtension
    #  extend Tibbr::ActiveResourceExtension

    cattr_accessor :cache_ttl
    cattr_accessor :main_part_id
    cattr_accessor :attachment_id_prefix
    cattr_accessor :chat_domain
    cattr_accessor :chat_url
    cattr_accessor :assertion_consumer_service_url

    class << self

      attr_accessor :curl
      #  curl = File.join(File.dirname( __FILE__ ), "..", "tools", "curl", "curl")
      def curl
        @curl ||= (RUBY_PLATFORM =~ /(:?mswin|mingw)/) ? File.join(File.dirname( __FILE__ ), "..", "tools", "curl", "curl") : "curl"
        #  curl = "C:/Harish/Projects/tibbr_demo/vendor/plugins/tibr_tibbrapi/tools/curl/curl"
      end


      attr_accessor :per_page
      def per_page
        @per_page ||= 30
      end

      attr_accessor :tcache
      def tcache
        @tcache || Rails.cache
      end

      def tcache_write(key, obj, options={})
        opt = {:expires_in => cache_ttl}.merge(options)
        opt[:expires_in]= valid_expires_in(opt[:expires_in])
        tcache.write(key, obj, opt)
      end

      def valid_expires_in expires_in
        return 0 if expires_in.nil?
         (k = expires_in.to_i) < 0 ? 0 : k
      rescue Exception => e
        return 0
      end

      def cache_store=(*store_option)
        @tcache = ActiveSupport::Cache.lookup_store(store_option)
      end

      def local_cache?
        tcache.is_a?(ActiveSupport::Cache::DalliStore) == false
      end

      logger = Rails.logger

      def from_xml(xml)
        new(ActiveResource::Formats[:xml].decode(xml))
      end

      def has_pagination_support?
        @has_pagination_support ||= [].respond_to?(:paginate)
      end

      def r_new options={}
        new(get("new", self.name.demodulize.underscore => (options||{})))
      end


      def benchmark(title, log_level = Logger::DEBUG, use_silence = true)
        if logger && logger.level <= log_level
          result = nil
          ms = Benchmark.ms { result = use_silence ? silence { yield } : yield }
          logger.add(log_level, '%s (%.1fms)' % [title, ms])
          result
        else
          yield
        end
      end

      # Silences the logger for the duration of the block
      def silence
        old_logger_level, logger.level = logger.level, Logger::ERROR if logger
        yield
      ensure
        logger.level = old_logger_level if logger
      end

      #  # Returns the name of method invoked in the current context
      #  # from: http://www.ruby-forum.com/topic/75258
      #  # Author: Robert Klemme
      #  def this_method
      #     caller[0] =~ /`([^']*)'/ and $1
      #  end

    end

    def cache_key
      case
        when new?
      "#{ActiveSupport::Inflector.tableize(self.class.name.demodulize)}/new"
        when timestamp = self.attributes["updated_at"]
      "#{ActiveSupport::Inflector.tableize(self.class.name.demodulize)}/#{id}-#{timestamp.to_time.to_s(:number)}"
      else
      "#{ActiveSupport::Inflector.tableize(self.class.name.demodulize)}/#{id}"
      end
    end

    def tcache
      TibbrResource.tcache
    end

    # Next two methods are added to address the TimeZone problem in ActiveResource
    def created_at
      self.attributes["created_at"].to_time.in_time_zone
    end

    def updated_at
      self.attributes["updated_at"].to_time.in_time_zone
    end

    def actions
      @actions ||=(self.attributes["actions"]||"").split(",")
    end

    def context_properties
      @context_properties ||= (attributes['context_properties'] || ContextProperties.new)
    end

    def multipart?
      !multiparts.empty?
    end

    def multiparts
      return @multipart if @multipart
      @multipart =  process_attachments
    end

    def process_attachments hash=attributes, result = {}
      hash.each do |k, v|
        v ||= k
        if is_file?(v)
          make_part(hash, k, v, result)
        elsif v.is_a?(Hash)
          v.each do |key, val|
            process_attachments({key => val}, result)
          end
        elsif v.is_a?(Array)
          v.each do |ele|
            if ele.is_a?(ActiveResource::Base)
            process_attachments(ele.attributes, result)
            else
              process_attachments({ele => nil}, result)
          end
          end
        elsif v.is_a?(ActiveResource::Base)
          process_attachments(v.attributes, result)
        end
      end
      result
    end

    def make_part hash, k, v, result
      #part_id = "%s_part_%d" % [Tibbr::TibbrResource.attachment_id_prefix, result.size]
      part_id = "#{Tibbr::TibbrResource.attachment_id_prefix}_part_#{result.size}"
      hash[k] = part_id
      result[part_id] = v
    end

    def is_list_or_hash?(data)
      data.is_a?(Hash) or data.is_a?(Array)
    end

    def is_file?(data)
      data.respond_to?(:read) and data.respond_to?(:path)
    end

    def create_url
      host_part = "#{self.class.site.scheme}://#{self.class.site.host}:#{self.class.site.port}"
      posturl = "#{host_part}/#{self.class.collection_path.gsub(/^\//, "")}"
    end

    def update_url
      host_part = "#{self.class.site.scheme}://#{self.class.site.host}:#{self.class.site.port}"
      posturl = "#{host_part}/#{self.class.element_path(URI.escape(self.id.to_s)).gsub(/^\//, "")}"
    end

    def multipart_send(url = nil, method = :post )
      begin
        parts = multiparts
        multipart = Multipart.new(Tibbr::TibbrResource.main_part_id, self.to_xml, parts)
        res = multipart.post(url, method)
        @multipart= nil
        valid_codes = ["200","201", "202"]
        if valid_codes.include?(res.code)
          load_attributes_from_response(res)
          return true
        else
          populate_error(res) if !res.read_body.blank?
          return false
        end
      rescue Exception =>excep
        populate_error(excep)
        return false
      end

      # http://www.ruby-forum.com/topic/152849#680706
      # http://forums.devshed.com/php-development-5/curl-post-request-question-254010.html
      # TODO use the rest client to send the parts
      # return true/false based on the status
      # populate the error messages upon error
    end

    def load_from_response(response)
      response.tap{|res| load_attributes_from_response(res) if res.instance_of?(Net::HTTPOK)}.instance_of?(Net::HTTPOK)
    end

    alias_method :http_delete, :delete

    class << self
      def simple_collection(collection, rclass)
        return nil if collection == nil or (rclass.nil? and block.nil?)
        collection.collect! {|record| (rclass.class == Proc) ? rclass.call(record) : rclass.new(record)}
      end

      def paginate_collection(collection, rclass=nil, &block)
        return nil if collection == nil or (rclass.nil? and block.nil?)
        if collection.is_a?(Hash) && collection["type"] == "collection"
          collectables = collection.values.find{|c| c.is_a?(Hash) || c.is_a?(Array) }
          collectables = [collectables].compact unless collectables.kind_of?(Array)
          if TibbrResource.has_pagination_support?
            WillPaginate::Collection.create(collection["current_page"], collection["per_page"], collection["total_entries"]) do |pager|
              pager.replace simple_collection(collectables, block || rclass)
            end
          else
            simple_collection(collectables, block || rclass)
          end
        else
          simple_collection(collection, block || rclass)
        end
      end

      def extract_params(args, k=3)
        options = args.extract_options!
        if k == 1
         (args.slice!(0)||nil)
        elsif k == 2
          [(options[:page]||1), (options[:per_page]||TibbrResource.per_page), options]
        elsif k == 4
          [(args.slice!(0)||nil),(args.slice!(0)||nil), (options[:page]||1), (options[:per_page].blank? ? TibbrResource.per_page : options[:per_page]), options]
        elsif k == 5
          [(args.slice!(0)||nil),(args.slice!(0)||nil),(args.slice!(0)||nil), (options[:page]||1), (options[:per_page].blank? ? TibbrResource.per_page : options[:per_page]), options]
        else
          [(args.slice!(0)||nil),(options[:page]||1), (options[:per_page].blank? ? TibbrResource.per_page : options[:per_page]), options]
        end
      end
    end
  end
end unless defined?(Tibbr::TibbrResource)
