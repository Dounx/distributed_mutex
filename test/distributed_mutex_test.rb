# frozen_string_literal: true

require_relative "helper"

class TestDistributedMutex < Minitest::Test
  REDIS = Redis.new
  KEY_PREFIX = "test:distributed_mutex"

  def setup
    @mutex = build_mutex
  end

  def test_synchronize
    @mutex.synchronize { 1 + 1 == 2 }
    assert !@mutex.locked?
  end

  def test_wait_synchronize
    @mutex.synchronize(wait: true) { 1 + 1 == 2 }
    assert !@mutex.locked?
  end

  def test_synchronize_with_raise
    @mutex.synchronize { raise }
  rescue StandardError
    assert !@mutex.locked?
  end

  def test_wait_synchronize_with_raise
    @mutex.synchronize(wait: true) { raise }
  rescue StandardError
    assert !@mutex.locked?
  end

  def test_extend_lock
    @mutex.synchronize do
      assert @mutex.extend_lock(160)
      assert((@mutex.ttl - 160).abs < 1)
    end
    assert !@mutex.extend_lock(160)
  end

  def test_ttl
    @mutex.synchronize { assert @mutex.ttl.positive? }
    assert @mutex.ttl.zero?
  end

  def test_locked?
    @mutex.synchronize { assert @mutex.locked? }
    assert !@mutex.locked?
  end

  def test_try_lock
    assert @mutex.send(:try_lock)
    assert @mutex.send(:unlock)
  end

  def test_try_lock_in_time
    mutex = build_mutex(wait_time: 3)
    key = mutex.send(:key)
    other_mutex = DistributedMutex.new(REDIS, key)
    assert other_mutex.send(:lock)
    background = Thread.new do
      assert mutex.send(:try_lock)
      assert mutex.send(:unlock)
    end
    assert other_mutex.send(:unlock)
    background.join
  end

  def test_try_lock_timeout
    mutex = build_mutex(wait_time: 1)
    key = mutex.send(:key)
    other_mutex = DistributedMutex.new(REDIS, key)
    assert other_mutex.send(:lock)
    background = Thread.new { assert !mutex.send(:try_lock) }
    sleep(1)
    assert other_mutex.send(:unlock)
    background.join
  end

  def test_lock
    assert @mutex.send(:lock)
    assert @mutex.locked?
    assert @mutex.send(:unlock)
  end

  def test_can_not_lock_if_locked
    assert @mutex.send(:lock)
    assert !@mutex.send(:lock)
    assert @mutex.send(:unlock)
  end

  def test_unlock
    test_lock
    assert !@mutex.locked?
  end

  def test_can_not_unlock_other_lock
    other_mutex = build_mutex
    assert other_mutex.send(:lock)
    assert !@mutex.send(:unlock)
    assert other_mutex.send(:unlock)
  end

  def build_mutex(timeout: 60, wait_time: 60)
    DistributedMutex.new(REDIS, "#{KEY_PREFIX}:#{SecureRandom.uuid}", timeout, wait_time)
  end
end
