# frozen_string_literal: true

# Sample job to test SidekiqSearch::Fetchers::Running
class RunningFetcherJob
  include Sidekiq::Job

  sidekiq_options retry: 0

  def perform(sleep_for)
    sleep(sleep_for)
  end
end
