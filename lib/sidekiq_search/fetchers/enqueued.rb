# frozen_string_literal: true

module SidekiqSearch
  module Fetchers
    class Enqueued
      # (see SidekiqSearch::Parameters#call!)
      # @return [Array<Hash>]
      def call(from_queues:)
        @from_queues = from_queues

        serialized_enqueued_jobs
      end

      private

      def queues
        Sidekiq::Queue.all.filter_map { |queue| queue if @from_queues.include?(queue.name) }
      end

      def enqueued_jobs
        queues.flat_map(&:to_a)
      end

      def serialized_enqueued_jobs
        enqueued_jobs.map { |job_object| serialize_sidekiq_job_record(job_object:, category: 'enqueued') }
      end

      def serialize_sidekiq_job_record(job_object:, category:)
        SidekiqSearch::Serializers::JobRecord.call(job_object:, category:)
      end
    end
  end
end
