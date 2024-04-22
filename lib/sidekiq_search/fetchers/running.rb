# frozen_string_literal: true

module SidekiqSearch
  module Fetchers
    class Running
      # (see SidekiqSearch::Parameters#call!)
      # @return [Array<Hash>]
      def call(from_queues:)
        @from_queues = from_queues

        serialized_running_jobs
      end

      private

      def running_set
        # See comments about WorkSet in the source code:
        # https://github.com/sidekiq/sidekiq/blob/main/lib/sidekiq/api.rb#L1093
        Sidekiq::WorkSet.new
      end

      def running_jobs
        running_set.to_a
      end

      def serialized_running_jobs
        running_jobs.filter_map do |_, _, work_object|
          next if !@from_queues.include?(work_object.queue)

          serialize_sidekiq_work(work_object:)
        end
      end

      def serialize_sidekiq_work(work_object:)
        SidekiqSearch::Serializers::Work.call(work_object:)
      end
    end
  end
end
