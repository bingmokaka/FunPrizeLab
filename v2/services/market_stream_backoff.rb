# frozen_string_literal: true

module MarketStreamBackoff
  module_function

  def delay(attempt, base:, max:, jitter: 0, rng: Random)
    exponential_delay = [base * (2**attempt), max].min
    return exponential_delay if jitter.to_f <= 0

    exponential_delay + (rng.rand * jitter)
  end
end
