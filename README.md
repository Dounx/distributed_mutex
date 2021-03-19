# DistributedMutex

Simple distributed locks with Redis.

## Installation (Not be uploaded to rubygems yet)

```bash
gem install distributed_mutex
```

Or you can install via Bundler if you are using Rails. Add this line to your application's Gemfile:

```ruby
gem 'distributed_mutex'
```

And then execute:

```ruby
bundle
```

## Basic Usage

```ruby
redis = Redis.new
key = "foo:bar"
mutex = DistributedMutex.new(redis, key)

# Not wait for a lock 
mutex.synchronize { 1 + 1 == 2 }

# Wait for a lock
mutex.synchronize(wait: true) { 1 + 1 == 2 }

# Extend a existed lock
mutex.extend_lock(100)
```

## Build

```bash
git clone https://github.com/Dounx/distributed_mutex
cd distributed_mutex
gem build distributed_mutex.gemspec
gem install --local distributed_mutex-*.gem
```

## Rake

List of available tasks.

```bash
rake --tasks
```

## License

DistributedMutex is an open-sourced software licensed under the [MIT license](LICENSE).
