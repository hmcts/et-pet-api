# ET to ATOS File Transfer

This gem is intended to be used in the Employment Tribunal JADU Replacement project. It keeps the ATOS interface separate with the
goal of being able to use it as a standalone rack app OR just mount it inside a rails app.

However, the first stage is just to use it in a rails app - with the dependencies satisfied by that (listed below).
If a decision is made to keep it properly isolated for security then with a little bit more work to provide the dependencies,
it could be used as a standalone rack app.

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'et_atos_file_transfer'
```

And then execute:

$ bundle

Or install it yourself as:

$ gem install et_atos_file_transfer

## Dependencies

Currently, the application relies on the following from the app where it is mounted

1. Active Record
2. Active Storage
3. ExportedFile model

## Usage

### To Mount Into Rails App

In your config/routes.rb

```ruby

  mount EtAtosFileTransfer, at: '/atos_api'


```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
