# frozen_string_literal: true

# Sample job to test SidekiqSearch::Fetchers::Running
class RunningFetcherJob
  include Sidekiq::Job

  def perform(sleep_for)
    sleep(sleep_for)
  end
end
