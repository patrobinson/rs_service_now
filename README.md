# RsServiceNow

A Ruby Soap ServiceNow interface.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rs_service_now'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rs_service_now

## Usage

```ruby
sn = RsServiceNow::Company.new user, password, instance
```

### Retrieve
Get every field from matching records. This is a quick way to retrieve any number of records, 250 at a time.

Using an encodedQuery. This can be easily retrieved by conducting a search in Service-Now, right clicking the very end of the search string and selecting "Copy query"

```ruby
sn.request :encoded_query => "active=true"
```

### Export
Retrieve a data export from Service-Now. Should be more efficient than Retrieve as by default it can export 10000 records at a time, instead of 250. This is experimental at the moment that has not been thoroughly tested.

```ruby
sn.export :encoded_query => "active=true"
```

## Contributing

1. Fork it ( https://github.com/nemski/rs_service_now/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
