# frozen_string_literal: true

require "securerandom"

# Cross-process locking using Redis
#
# Every block should new a instance
class DistributedMutex
  TRY_TIME_INTERVAL = 0.1
  DEFAULT_TIMEOUT = 60
  DEFAULT_WAIT_TIME = 60

  # timeout should be maximum execution time of the block
  def initialize(redis, key, timeout = DEFAULT_TIMEOUT, wait_time = DEFAULT_WAIT_TIME)
    @redis = redis
    @key = key
    @uuid = SecureRandom.uuid
    @timeout = timeout
    @wait_time = wait_time
  end

  def synchronize(wait: false)
    status = wait ? try_lock : lock
    return false unless status

    yield
  ensure
    unlock
  end

  # Use lua script to maintain atomicity
  def extend_lock(extend_time)
    extend_lua = %(
      if (redis.call('get', KEYS[1]) == ARGV[1])
      then
        return redis.call('expire', KEYS[1], tonumber(ARGV[2]))
      else
        return 0
      end
    )
    redis.eval(extend_lua, keys: [key], argv: [uuid, extend_time]).positive?
  end

  def ttl
    locked? ? redis.ttl(key) : 0
  end

  def locked?
    redis.get(key) == uuid
  end

  private

  attr_reader :redis, :key, :uuid, :timeout, :wait_time

  def try_lock
    try_times = (wait_time / TRY_TIME_INTERVAL).to_i
    try_times.times do
      return true if lock

      sleep(TRY_TIME_INTERVAL)
    end
    false
  end

  # Use lua script to maintain atomicity
  def lock
    lock_lua = %(
      if (redis.call('setnx', KEYS[1], ARGV[1]) < 1)
      then
        return 0
      end
      return redis.call('expire', KEYS[1], tonumber(ARGV[2]))
    )
    redis.eval(lock_lua, keys: [key], argv: [uuid, timeout]).positive?
  end

  # Use lua script to maintain atomicity
  def unlock
    unlock_lua = %(
      if (redis.call('get', KEYS[1]) == ARGV[1])
      then
        return redis.call('del', KEYS[1])
      else
        return 0
      end
    )
    redis.eval(unlock_lua, keys: [key], argv: [uuid]).positive?
  end
end
