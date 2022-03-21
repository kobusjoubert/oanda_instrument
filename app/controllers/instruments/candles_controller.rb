class Instruments::CandlesController < ApplicationController
  before_action :set_instrument, only: [:show]

  # GET /instruments/:instrument/candles
  def show
    @result = $oanda_client.instrument(@instrument).candles(instruments_params).show
  end

  private

  def set_instrument
    @instrument = params[:instrument]
  end

  def instruments_params
    params.permit(:price, :granularity, :count, :from, :to, :smooth, :includeFirst, :dailyAlignment, :alignmentTimezone, :weeklyAlignment)
  end
end
