# frozen_string_literal: true

module SidekiqSearch
  # Main service which orchestrates everything
  class Jobs
    # (see SidekiqSearch::Parameters#call!)
    # @return [Array<Hash>]
    def call(...)
      validate_and_set_parameters!(...)

      @from_categories.map { |name| send(:"serialized_#{name}_jobs") }.flatten
    end

    private

    def validate_and_set_parameters!(...)
      parameters = SidekiqSearch::Parameters.new.call!(...)

      @from_categories = parameters[:from_categories]
      @from_queues = parameters[:from_queues]
    end

    def serialized_enqueued_jobs
      SidekiqSearch::Fetchers::Enqueued.new.call(from_queues: @from_queues)
    end

    def serialized_scheduled_jobs
      SidekiqSearch::Fetchers::SortedEntry.new.call(
        from_queues: @from_queues,
        set_class: Sidekiq::ScheduledSet,
        set_category: 'scheduled'
      )
    end

    def serialized_retried_jobs
      SidekiqSearch::Fetchers::SortedEntry.new.call(
        from_queues: @from_queues,
        set_class: Sidekiq::RetrySet,
        set_category: 'retried'
      )
    end

    def serialized_dead_jobs
      SidekiqSearch::Fetchers::SortedEntry.new.call(
        from_queues: @from_queues,
        set_class: Sidekiq::DeadSet,
        set_category: 'dead'
      )
    end

    def serialized_running_jobs
      SidekiqSearch::Fetchers::Running.new.call(from_queues: @from_queues)
    end
  end
end
