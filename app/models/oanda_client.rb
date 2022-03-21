class OandaClient
  # Make dRuby send OandaClient instances as dRuby references, not copies.
  include DRb::DRbUndumped

  OANDA_ACCOUNTS = {
    live:     '001-001-123456-001',
    practice: '001-001-123456-002'
  }

  attr_reader :oanda_client

  def initialize(options = {})
    oanda_account  = ['production', 'backtest'].include?(Rails.env) ? OANDA_ACCOUNTS[:live] : OANDA_ACCOUNTS[:practice]
    practice       = ['production', 'backtest'].include?(Rails.env) ? false : true
    worker_account = Account.find_by!(practice: practice, account: oanda_account)
    @oanda_client  = OandaApiV20.new(access_token: worker_account.access_token, practice: worker_account.practice, debug: ['development', 'backtest'].include?(Rails.env))
  end
end

# https://ruby-doc.org/stdlib-2.3.0/libdoc/drb/rdoc/DRb.html
#
# We have a central object for communicating through the Oanda API.
# A dRuby reference to an object is not sufficient to prevent it being garbage collected!
#
# class OandaClientFactory
#   attr_reader :oanda_client
#
#   def initialize(options = {})
#     @oanda_client = OandaClient.new.oanda_client
#   end
# end
