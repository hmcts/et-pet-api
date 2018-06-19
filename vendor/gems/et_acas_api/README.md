# EtAcasApi

This gem provides 2 mountable engines that provide a JSON API to interface to the
employment tribunal's 'ACAS' service.

The first mountable engine is intended to be used in the API project to actually provide the service
and the second mountable engine is a fake service that can be used for testing.  It will be packaged
into a docker container to be used in full system testing where connecting to the real system is not
possible.

## Usage

In your routes file in the API application - do this :-

```

mount EtAcasApi::Engine, at: '/acas_api'

```

or, to mount the fake server :-

```

mount EtAcasApi::FakeServer::Engine, at: '/fake_acas_server'

```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'et_acas_api'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install et_acas_api
```

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
