# frozen_string_literal: true

module SidekiqSearch
  module Serializers
    class Work
      # @param work_object [Sidekiq::Work]
      # @return [Hash]
      def self.call(work_object:)
        job_object = work_object.job

        {
          job_object:,
          class: job_object.klass,
          arguments: job_object.args,
          created_at: job_object.created_at, # Time
          enqueued_at: job_object.enqueued_at, # Time
          queue_name: work_object.queue,
          sidekiq_job_id: job_object.jid,
          activejob_job_id: job_object.item['job_id'],
          category: 'running',
          work_object:,
          run_at: work_object.run_at
        }
      end
    end
  end
end
