# frozen_string_literal: true

# Sample job to test SidekiqSearch::Fetchers::SortedEntry for Sidekiq::DeadSet
class DeadSetJob
  include Sidekiq::Job

  sidekiq_options retry: 0

  def perform(_sample_parameter)
    raise
  end
end
