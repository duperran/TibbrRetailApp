#http://stanislavvitvitskiy.blogspot.com/2008/12/multipart-post-in-ruby.html

require 'net/http'
require 'uri'
require 'pp'
require 'mime/types'

class Multipart  
  
  def initialize( main_part_id, main_part_content, file_names )  
    @file_names = file_names  
    @main_part_id = main_part_id
    @main_part_content = main_part_content
  end
  
  def post( to_url, method = :post )  
    boundary = "###-------#{Time.new}-----####"
    
    parts = []  
    streams = []
    # write main part first
    parts << StringPart.new( "--" + boundary + "\r\n")
    parts << StringPart.new("Content-Disposition: name=\"#{@main_part_id}\";\"\r\n" +  
      "Content-ID: #{@main_part_id}\r\n\r\n"+
      "Content-Type: application/xml\r\n\r\n" +  
    @main_part_content + "\r\n\r\n")
    parts << StringPart.new( "\r\n--" + boundary + "\r\n")
    
    @file_names.each do |param_name, filestream|
      raise 'mutlipartsend: empty file object' if filestream.blank?
      
      filename= filestream.respond_to?(:original_path) ? filestream.original_path : filestream.path
      ctype = filestream.respond_to?(:content_type) ? filestream.content_type: nil
      fsize = filestream.respond_to?(:lstat) ? filestream.lstat.size : filestream.size
      
      
      if !ctype
        begin
            pos = filename.rindex('/') # if filename is a path
            fname = filename[pos + 1, filename.length - pos]
            mm = MIME::Types.type_for(fname)
            ctype = mm.first.content_type if !mm.blank?
        rescue Exception => e
          p e.message
        end
      end
      if !ctype
        ctype= 'application/binary'
        p "mutlipartsend: failed to determine contenttype for #{filename}. using application/binary"
      end
      
      
      parts << StringPart.new("Content-Disposition: name=\"" + param_name.to_s + "\"; filename=\"" + filename + "\"\r\n" +  
        "Content-Type: #{ctype}\r\n\r\n")
        #"Content-Type: application/binary\r\n\r\n")
      begin
        stream = File.open(filestream.path,"rb")
        streams << stream 
        parts << StreamPart.new(stream, fsize)
        parts << StringPart.new( "\r\n--" + boundary + "\r\n" )
      rescue Exception => e
        p 'failed to load filestream '+ filestream.path
        p e.message
        raise 'failed to load filestream ' + e.message
      end
    
    end
    
    post_stream = MultipartStream.new( parts )  
    
    url = URI.parse( to_url )
    req = method == :post ? Net::HTTP::Post.new(url.path) : Net::HTTP::Put.new(url.path)
    req.content_length = post_stream.size
    req.content_type = 'multipart/mixed; boundary=' + boundary
    ActiveResource::Base.headers.each {|k,v| req["#{k}"]=v}
    req.body_stream = post_stream  
    res = Net::HTTP.new(url.host, url.port).start {|http| http.request(req) }  
    
    streams.each do |stream|  
      stream.close();  
    end  
    
    res  
  end  
  
end  

class StreamPart  
  def initialize( stream, size )  
    @stream, @size = stream, size  
  end  
  
  def size  
    @size  
  end  
  
  def read( offset, how_much )  
    @stream.read( how_much )  
  end  
end  

class StringPart  
  def initialize ( str )  
    @str = str  
  end  
  
  def size  
    @str.length  
  end  
  
  def read ( offset, how_much )  
    @str[offset, how_much]  
  end  
end  

class MultipartStream  
  def initialize( parts )  
    @parts = parts  
    @part_no = 0;  
    @part_offset = 0;  
  end  
  
  
  
  def size  
    total = 0  
    @parts.each do |part|  
      total += part.size  
    end  
    total  
  end  
  
  def read ( how_much )  
    if @part_no >= @parts.size  
      return nil;  
    end  
    
    how_much_current_part = @parts[@part_no].size - @part_offset  
    
    how_much_current_part = if how_much_current_part > how_much  
      how_much  
    else  
      how_much_current_part  
    end  
    
    how_much_next_part = how_much - how_much_current_part  
    
    current_part = @parts[@part_no].read(@part_offset, how_much_current_part )  
    
    if how_much_next_part > 0  
      @part_no += 1
      @part_changed=true
      @part_offset = 0  
      next_part = read( how_much_next_part  )  
      current_part + if next_part  
        next_part  
      else  
        ''  
      end  
    else  
      @part_offset += how_much_current_part  
      current_part  
    end  
  end  
  
end