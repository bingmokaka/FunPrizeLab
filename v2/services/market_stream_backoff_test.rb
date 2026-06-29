# frozen_string_literal: true

require 'minitest/autorun'
require_relative 'market_stream_backoff'

class MarketStreamBackoffTest < Minitest::Test
  class FixedRng
    def initialize(value)
      @value = value
    end

    def rand
      @value
    end
  end

  def test_initial_delay_uses_base_for_attempt_zero
    assert_equal 1, MarketStreamBackoff.delay(0, base: 1, max: 120)
  end

  def test_delay_grows_exponentially
    assert_equal 1, MarketStreamBackoff.delay(0, base: 1, max: 120)
    assert_equal 2, MarketStreamBackoff.delay(1, base: 1, max: 120)
    assert_equal 4, MarketStreamBackoff.delay(2, base: 1, max: 120)
    assert_equal 8, MarketStreamBackoff.delay(3, base: 1, max: 120)
  end

  def test_delay_is_capped_at_maximum
    assert_equal 120, MarketStreamBackoff.delay(10, base: 1, max: 120)
  end

  def test_zero_jitter_preserves_existing_production_default
    assert_equal 8, MarketStreamBackoff.delay(3, base: 1, max: 120, jitter: 0)
  end

  def test_jitter_stays_within_configured_bounds
    base_delay = MarketStreamBackoff.delay(3, base: 1, max: 120, jitter: 0)
    low_delay = MarketStreamBackoff.delay(3, base: 1, max: 120, jitter: 5, rng: FixedRng.new(0.0))
    high_delay = MarketStreamBackoff.delay(3, base: 1, max: 120, jitter: 5, rng: FixedRng.new(0.999))

    assert_operator low_delay, :>=, base_delay
    assert_operator high_delay, :<, base_delay + 5
  end
end
