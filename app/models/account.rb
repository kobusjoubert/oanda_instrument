class Account
  REQUIRED_ATTRIBUTES = [:practice, :account].freeze

  extend AttrEncrypted

  attr_accessor  :practice, :account
  attr_reader    :key_base, :key_access_token, :key_access_token_iv
  attr_encryptor :access_token, key: ENV['ACCESS_TOKEN_KEY'] # The same key must be used for OandaWorker, OandaData & OandaInstrument!

  def initialize(options = {})
    options.symbolize_keys!
    missing_attributes = REQUIRED_ATTRIBUTES - options.keys
    raise ArgumentError, "The #{missing_attributes} attributes are missing" unless missing_attributes.empty?

    options.each do |key, value|
      self.send("#{key}=", value) if self.respond_to?("#{key}=")
    end

    @key_base            = "#{practice ? 'practice' : 'live'}:accounts:#{account}"
    @key_access_token    = "#{key_base}:encrypted_access_token"
    @key_access_token_iv = "#{key_base}:encrypted_access_token_iv"
  end

  class << self
    def find_by!(attributes = {})
      attributes.symbolize_keys!
      missing_attributes = REQUIRED_ATTRIBUTES - attributes.keys
      raise ArgumentError, "The #{missing_attributes} attributes are missing" unless missing_attributes.empty?
      encrypted_access_token    = Base64.decode64($redis.get("#{attributes[:practice] ? 'practice' : 'live'}:accounts:#{attributes[:account]}:encrypted_access_token"))
      encrypted_access_token_iv = Base64.decode64($redis.get("#{attributes[:practice] ? 'practice' : 'live'}:accounts:#{attributes[:account]}:encrypted_access_token_iv"))
      raise OandaData::RecordNotFound, 'Account not found. Please update your access token and try again.' unless encrypted_access_token && encrypted_access_token_iv

      Account.new(practice: attributes[:practice], account: attributes[:account], encrypted_access_token: encrypted_access_token, encrypted_access_token_iv: encrypted_access_token_iv)
    end
  end
end
