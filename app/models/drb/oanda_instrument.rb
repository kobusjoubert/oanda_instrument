require 'drb/drb'

class DRb::OandaInstrument
  attr_reader :uri

  def initialize(options = {})
    # Disable eval() and friends.
    $SAFE = 1

    # We cannot read the uri from a config file because of $SAFE above.
    @uri = 'druby://127.0.0.1:8686'
  end

  def start_server_and_connect_client
    start
    connect
  end

  # Do not start the DRb server with the puma preloaded application. Start the server
  # only on the first puma worker, Worker 0. This can be done in the on_worker_boot block.
  # We want only one process connecting to the Oanda API to prevent the following from happening.
  #
  #   oanda_api_v20-api-fxtrade.oanda.com:443: Waiting for an available connection, all 2 connections are checked out.
  def start
    if DRb.primary_server
      log 'DRb server already started.'
      return
    end

    # begin
    #   DRb.current_server
    #   return
    # rescue DRb::DRbServerNotFound
    # end

    oanda_client = OandaClient.new

    begin
      log 'DRb server starting up...'
      DRb.start_service(uri, oanda_client, verbose: ['development', 'backtest'].include?(Rails.env))
      log 'DRb server successfully started!'

      # Wait for the drb server thread to finish before exiting.
      # DRb.thread.join

      # Or move to different ThreadGroup to avoid mongrel hang on exit.
      ThreadGroup.new.add(DRb.thread)
    rescue Errno::EADDRINUSE
      log 'DRb server already started!'
    end
  end

  # Connect all puma workers to the server and instantiate $oanda_client on each puma worker.
  # This can be done in the on_worker_boot block.
  def connect
    begin
      log 'DRb client connecting to server...'
      DRb.start_service
      $oanda_client = DRbObject.new_with_uri(uri).oanda_client
      log 'DRb client successfully connected to server!'
    rescue Errno::ECONNREFUSED, DRb::DRbConnError
      # We will only connect on puma workers boot, not when preloading initial app.
      log 'DRb client failed to connect to server!'
    end
  end

  private

  def log(message)
    printf "[#{Process.pid}] #{message}\n"
  end
end
