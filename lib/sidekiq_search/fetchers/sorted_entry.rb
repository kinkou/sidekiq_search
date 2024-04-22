# frozen_string_literal: true

module SidekiqSearch
  module Fetchers
    class SortedEntry
      # (see SidekiqSearch::Parameters#call!)
      # @return [Array<Hash>]
      def call(from_queues:, set_class:, set_category:)
        @from_queues = from_queues

        @set_class = set_class
        @set_category = set_category

        serialized_jobs
      end

      private

      def set
        @set_class.new
      end

      def jobs
        set.to_a
      end

      def serialized_jobs
        jobs.filter_map do |job_object|
          next if !@from_queues.include?(job_object.queue)

          serialize_sidekiq_sorted_entry(job_object:)
        end
      end

      def serialize_sidekiq_sorted_entry(job_object:)
        SidekiqSearch::Serializers::JobRecord.call(job_object:, category: @set_category)
      end
    end
  end
end
