# frozen_string_literal: true

require 'sidekiq/api'

require_relative 'sidekiq_search/version'

# Top-level namespace
class SidekiqSearch
  JOB_CATEGORIES = %w[
    enqueued
    scheduled
    retried
    dead
    running
  ].freeze

  def self.jobs(...)
    new.jobs(...)
  end

  # @param from_categories [Array<String>]
  # @param from_queues [Array<String>]
  # @return [Array<Hash>]
  def jobs(from_categories:, from_queues:)
    @from_categories = from_categories || []
    @from_queues = from_queues || []

    check_parameters!

    [
      serialized_enqueued_jobs,
      serialized_scheduled_jobs,
      serialized_retried_jobs,
      serialized_dead_jobs,
      serialized_running_jobs
    ].flatten
  end

  private

  # enqueued

  def queues
    return [] if !@from_categories.include?('enqueued')

    Sidekiq::Queue.all.filter_map { _1 if @from_queues.include?(_1.name) }
  end

  def enqueued_jobs
    queues.flat_map(&:to_a)
  end

  def serialized_enqueued_jobs
    enqueued_jobs.map { serialize_job_record(job_object: _1, category: 'enqueued') }
  end

  # scheduled

  def scheduled_set
    return [] if !@from_categories.include?('scheduled')

    Sidekiq::ScheduledSet.new
  end

  def scheduled_jobs
    scheduled_set.to_a
  end

  def serialized_scheduled_jobs
    scheduled_jobs.filter_map do |job_object|
      serialize_sorted_entry(job_object:, category: 'scheduled') if @from_queues.include?(job_object.queue)
    end
  end

  # retried

  def retried_set
    return [] if !@from_categories.include?('retried')

    Sidekiq::RetrySet.new
  end

  def retried_jobs
    retried_set.to_a
  end

  def serialized_retried_jobs
    retried_jobs.filter_map do |job_object|
      serialize_sorted_entry(job_object:, category: 'retried') if @from_queues.include?(job_object.queue)
    end
  end

  # dead

  def dead_set
    return [] if !@from_categories.include?('dead')

    Sidekiq::DeadSet.new
  end

  def dead_jobs
    dead_set.to_a
  end

  def serialized_dead_jobs
    dead_jobs.filter_map do |job_object|
      serialize_sorted_entry(job_object:, category: 'dead') if @from_queues.include?(job_object.queue)
    end
  end

  # running

  def running_set
    return [] if !@from_categories.include?('running')

    # See comments about WorkSet in the source code:
    # https://github.com/sidekiq/sidekiq/blob/main/lib/sidekiq/api.rb#L1093
    Sidekiq::WorkSet.new
  end

  def running_jobs
    running_set.to_a
  end

  def serialized_running_jobs
    running_jobs.filter_map do |_, _, process_object|
      serialize_sidekiq_process(process_object:) if @from_queues.include?(process_object.queue)
    end
  end

  # serializers

  def serialize_job_record(job_object:, category:)
    {
      job_object:,
      class: job_object.klass,
      arguments: job_object.args,
      created_at: job_object.created_at, # Time
      enqueued_at: job_object.enqueued_at, # Time
      queue_name: job_object.queue,
      sidekiq_job_id: job_object.jid,
      activejob_job_id: job_object.item['job_id'],
      category:
    }
  end

  alias serialize_sorted_entry serialize_job_record

  def serialize_sidekiq_process(process_object:)
    job_object = process_object.job

    {
      job_object:,
      class: job_object.klass,
      arguments: job_object.args,
      created_at: job_object.created_at, # Time
      enqueued_at: job_object.enqueued_at, # Time
      queue_name: process_object.queue,
      sidekiq_job_id: job_object.jid,
      activejob_job_id: job_object.item['job_id'],
      category: 'running',
      process_object:,
      run_at: process_object.run_at
    }
  end

  def check_parameters!
    if @from_categories.empty?
      raise ArgumentError, '`from_categories` parameter must contain at least one category name'
    end

    raise ArgumentError, '`from_queues` parameter must contain at least one queue name' if @from_queues.empty?

    @from_categories.each do |category|
      next if JOB_CATEGORIES.include?(category)

      raise ArgumentError, "Unknown category `#{category}`. Must be one of: #{JOB_CATEGORIES.join(", ")}"
    end

    true
  end
end
