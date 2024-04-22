# frozen_string_literal: true

require 'sidekiq/api'

require_relative 'sidekiq_search/version'

require_relative 'sidekiq_search/parameters'

require_relative 'sidekiq_search/serializers/job_record'
require_relative 'sidekiq_search/serializers/work'

require_relative 'sidekiq_search/fetchers/enqueued'
require_relative 'sidekiq_search/fetchers/sorted_entry'
require_relative 'sidekiq_search/fetchers/running'

require_relative 'sidekiq_search/jobs'

module SidekiqSearch
  # Allowed job category names
  JOB_CATEGORIES = %w[
    enqueued
    scheduled
    retried
    dead
    running
  ].freeze

  # (see SidekiqSearch::Jobs#call)
  def self.jobs(...)
    SidekiqSearch::Jobs.new.call(...)
  end
end
