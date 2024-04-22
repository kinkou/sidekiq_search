# frozen_string_literal: true

module SidekiqSearch
  class Util
    def self.flush_all
      Sidekiq.redis(&:flushall)
    end
  end
end
