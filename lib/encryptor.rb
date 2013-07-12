
require 'digest/sha2'
require 'openssl'
class Encryptor
  class InvalidMessage < StandardError; end
  (OpenSSLCipherError = OpenSSL::Cipher.const_defined?(:CipherError) ? OpenSSL::Cipher::CipherError : OpenSSL::CipherError) unless defined?(OpenSSLCipherError)
  def initialize(secret, client_key, cipher = 'aes-128-cbc')
    @secret     = secret
    @cipher     = cipher
    @client_key = client_key
  end

  def encrypt(value)
    cipher = new_cipher
    # Rely on OpenSSL for the initialization vector
    iv = iv_for_cipher(new_cipher.iv_len)

    cipher.encrypt 
    cipher.key = @secret
    cipher.iv  = iv
    
    encrypted_data = cipher.update(Marshal.dump(value)) 
    encrypted_data << cipher.final
    ActiveSupport::Base64.encode64s(encrypted_data)
  end
  
  def decrypt(encrypted_message)
    # Encryptor class value issue while decrypt value less than 3 characters
    raise InvalidMessage if encrypted_message.to_s.length < 4
    cipher = new_cipher
    encrypted_data, iv = ActiveSupport::Base64.decode64(encrypted_message), iv_for_cipher(new_cipher.iv_len)
    
    cipher.decrypt
    cipher.key = @secret
    cipher.iv  = iv
    
    decrypted_data = cipher.update(encrypted_data)
    decrypted_data << cipher.final
    
    Marshal.load(decrypted_data)
  rescue OpenSSLCipherError, TypeError
    raise InvalidMessage
  end
  
  private
  def new_cipher
    OpenSSL::Cipher::Cipher.new(@cipher)
  end
  
  
  def verifier
    MessageVerifier.new(@secret)
  end
  
  def iv_for_cipher iv_len
    dt = iv_len <=256 ? Digest::SHA256 : (iv_len <= 384) ? Digest::SHA384 : (iv_len <= 512) ? Digest::SHA512 : Digest::SHA512
    digest = dt.new
    digest << @client_key
    digest.to_s[0,16]
  end
end