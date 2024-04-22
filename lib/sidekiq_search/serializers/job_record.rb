# frozen_string_literal: true

module SidekiqSearch
  module Serializers
    class JobRecord
      # @param job_object [Sidekiq::JobRecord, Sidekiq::SortedEntry]
      # @param category ["enqueued", "scheduled", "retried", "dead"]
      # @return [Hash]
      def self.call(job_object:, category:)
        {
          job_object:,
          class: job_object.klass,
          arguments: job_object.args,
          created_at: job_object.created_at, # returns Time
          enqueued_at: job_object.enqueued_at, # returns Time
          queue_name: job_object.queue,
          sidekiq_job_id: job_object.jid,
          activejob_job_id: job_object.item['job_id'],
          category:
        }
      end
    end
  end
end
