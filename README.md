# Ownership

Code ownership for Rails

Check out [Scaling the Monolith](https://ankane.org/scaling-the-monolith) for other tips

:tangerine: Battle-tested at [Instacart](https://www.instacart.com/opensource)

[![Build Status](https://github.com/ankane/ownership/workflows/build/badge.svg?branch=master)](https://github.com/ankane/ownership/actions)

## Installation

Add this line to your application’s Gemfile:

```ruby
gem "ownership"
```

## Getting Started

Ownership provides the ability to specify owners for different parts of the codebase. **We highly recommend owners are teams rather than individuals.** You can then use this information however you’d like, like routing errors to the correct team.

## Specifying Ownership

### Controllers

```ruby
class OrdersController < ApplicationController
  owner :logistics
end
```

You can use any options that `before_action` supports.

```ruby
class OrdersController < ApplicationController
  owner :logistics, only: [:index]
  owner :customers, except: [:index]
end
```

### Jobs

```ruby
class SomeJob < ApplicationJob
  owner :logistics
end
```

### Anywhere

```ruby
owner :logistics do
  # code
end
```

### Default

You can set a default owner with:

```ruby
Ownership.default_owner = :logistics
```

## Integrations

There are a few built-in integrations with other gems.

- [Active Record](#active-record)
- [Honeybadger](#honeybadger)
- [Marginalia](#marginalia)
- [Rollbar](#rollbar)

You can also add [custom integrations](#custom-integrations).

### Active Record

Active Record 7+ has the option to add comments to queries.

```sql
SELECT ...
/*application:MyApp,controller:posts,action:index,owner:logistics*/
```

Add to `config/application.rb`:

```ruby
config.active_record.query_log_tags_enabled = true
config.active_record.query_log_tags << :owner
```

### Honeybadger

[Honeybadger](https://github.com/honeybadger-io/honeybadger-ruby) tracks exceptions. This integration makes it easy to send exceptions to different projects based on the owner. We recommend having a project for each team.

```ruby
Ownership::Honeybadger.api_keys = {
  logistics: "token1",
  customers: "token2"
}
```

Also works with a proc

```ruby
Ownership::Honeybadger.api_keys = ->(owner) { ENV["#{owner.to_s.upcase}_HONEYBADGER_API_KEY"] }
```

### Marginalia

[Marginalia](https://github.com/basecamp/marginalia) adds comments to Active Record queries. If installed, the owner is added.

```sql
SELECT ...
/*application:MyApp,controller:posts,action:index,owner:logistics*/
```

This can be useful when looking at the most time-consuming queries on your database.

### Rollbar

[Rollbar](https://github.com/rollbar/rollbar-gem) tracks exceptions. This integration makes it easy to send exceptions to different projects based on the owner. We recommend having a project for each team.

```ruby
Ownership::Rollbar.access_token = {
  logistics: "token1",
  customers: "token2"
}
```

Also works with a proc

```ruby
Ownership::Rollbar.access_token = ->(owner) { ENV["#{owner.to_s.upcase}_ROLLBAR_ACCESS_TOKEN"] }
```

For version 3.1+ of the `rollbar` gem, add to `config/initializers/rollbar.rb`:

```ruby
config.use_payload_access_token = true
```

## Custom Integrations

You can define a custom block of code to run with:

```ruby
Ownership.around_change = proc do |owner, block|
  puts "New owner: #{owner}"
  block.call
  puts "Done"
end
```

Please don’t hesitate to [submit a pull request](https://github.com/ankane/ownership/pulls) if you create an integration that others can use.

Exceptions that bubble up from an `owner` block have the owner, which your exception reporting library can use.

```ruby
begin
  owner :logistics do
    raise "error"
  end
rescue => e
  puts e.owner # :logistics
end
```

## Other Useful Tools

- [GitHub Code Owners](https://github.com/blog/2392-introducing-code-owners) for code reviews

## Thanks

Thanks to [Nick Elser](https://github.com/nickelser) for creating this pattern.

## History

View the [changelog](https://github.com/ankane/ownership/blob/master/CHANGELOG.md).

## Contributing

Everyone is encouraged to help improve this project. Here are a few ways you can help:

- [Report bugs](https://github.com/ankane/ownership/issues)
- Fix bugs and [submit pull requests](https://github.com/ankane/ownership/pulls)
- Write, clarify, or fix documentation
- Suggest or add new features

To get started with development and testing:

```sh
git clone https://github.com/ankane/ownership.git
cd ownership
bundle install
bundle exec rake test
```
