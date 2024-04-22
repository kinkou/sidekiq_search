# frozen_string_literal: true

module SidekiqSearch
  # Validates and transforms input parameters
  class Parameters
    # @param from_categories [Array<String>]
    #   Non-empty list of categories. A category must be one of {SidekiqSearch::JOB_CATEGORIES}.
    # @param from_queues [Array<String>]
    #   Non-empty list of Sidekiq queues.
    # @return [Hash]
    def call!(from_categories:, from_queues:)
      @from_categories = from_categories
      @from_queues = from_queues

      transform_parameters!
      check_parameters!

      {
        from_categories: @from_categories,
        from_queues: @from_queues
      }
    end

    private

    def transform_parameters!
      @from_categories = [@from_categories].flatten
      @from_queues = [@from_queues].flatten
    end

    def check_parameters!
      check_from_categories_presence!
      check_from_queues_presence!
      check_categories_inclusion!

      true
    end

    def check_from_categories_presence!
      return if !@from_categories.empty?

      raise(
        ArgumentError,
        '`from_categories` parameter must contain at least one category name'
      )
    end

    def check_from_queues_presence!
      return if !@from_queues.empty?

      raise(
        ArgumentError,
        '`from_queues` parameter must contain at least one queue name'
      )
    end

    def check_categories_inclusion!
      @from_categories.each do |category|
        next if SidekiqSearch::JOB_CATEGORIES.include?(category)

        raise(
          ArgumentError,
          "Unknown category `#{category}`. Must be one of: #{SidekiqSearch::JOB_CATEGORIES.join(", ")}"
        )
      end
    end
  end
end
