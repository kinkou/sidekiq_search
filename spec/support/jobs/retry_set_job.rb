# frozen_string_literal: true

# Sample job to test SidekiqSearch::Fetchers::SortedEntry for Sidekiq::RetrySet
class RetrySetJob
  include Sidekiq::Job

  sidekiq_options retry: 1, dead: false

  sidekiq_retry_in { |_count, _exception, _job_hash| 10 }

  def perform(_sample_parameter)
    raise
  end
end
