Rails.application.config.after_initialize do
  require 'drb/oanda_instrument'

  if defined?(Rails::Console) && ['development', 'backtest'].include?(Rails.env)
    DRb::OandaInstrument.new.start_server_and_connect_client
  end
end
