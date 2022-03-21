# OandaInstrument

An API service with the sole purpose of returning candle data.

This service should be able to handle a great deal of concurrent requests, as much as the Rails Puma server can handle.

We will keep only one connection open to the [Oanda API](https://developer.oanda.com/rest-live-v20/best-practices/) using [Distributed Ruby](https://ruby-doc.org/stdlib-2.4.5/libdoc/drb/rdoc/DRb.html) to adhere to best practices and prevent being rate limited.

## Usage

### Development

Start the service

    bin/rails s

### Backtesting

Start the service

    RAILS_ENV=backtest bin/rails s --pid `pwd`/tmp/pids/server_backtest.pid

## Examples

### Welcome

    curl -i -XGET 'http://localhost:3200/public/welcome' -H 'Content-Type: application/json' -H 'X-User-Email: oanda_trader@translate3d.com' -H 'X-User-Token: TFq61Z7tP6A3Y18Lzz2j'

### Request Candle Data

    curl -i -XGET 'http://localhost:3200/instruments/EUR_USD/candles' -H 'Content-Type: application/json' -H 'X-User-Email: oanda_service@translate3d.com' -H 'X-User-Token: wwHcswxFo8Nxqsdyss1v'

## Developer Setup

Create the database

```ruby
bin/rails db:create
RAILS_ENV=backtest bin/rails db:create
```

Migrate the database

```ruby
bin/rails db:migrate
RAILS_ENV=backtest bin/rails db:migrate
```

Setup the database with the required authenticated users

```ruby
bin/rails db:seed
RAILS_ENV=backtest bin/rails db:seed
```
