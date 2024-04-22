# frozen_string_literal: true

# Sample job to test SidekiqSearch::Fetchers::Enqueued
class EnqueuedFetcherJob
  include Sidekiq::Job

  sidekiq_options queue: :not_processed, retry: 0

  def perform(sample_parameter)
    sample_parameter
  end
end
