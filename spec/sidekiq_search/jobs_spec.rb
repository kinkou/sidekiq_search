# frozen_string_literal: true

RSpec.describe SidekiqSearch::Jobs do
  let(:perform) { described_class.new.call(from_categories:, from_queues:) }

  let(:from_categories) { %w[enqueued scheduled retried dead running] }
  let(:from_queues) { %w[default] }

  let(:input_parameters) { { from_categories:, from_queues: } }
  let(:validated_parameters) { input_parameters }

  let(:parameters_validation_service) do
    instance_double(SidekiqSearch::Parameters, call!: validated_parameters)
  end

  let(:enqueued_jobs_fetcher) { instance_double(SidekiqSearch::Fetchers::Enqueued, call: enqueued_jobs) }
  let(:enqueued_jobs) { ['enqueued job fetcher result'] }

  let(:sorted_entry_type_jobs_fetcher) { instance_double(SidekiqSearch::Fetchers::SortedEntry) }

  let(:running_jobs_fetcher) { instance_double(SidekiqSearch::Fetchers::Running, call: running_jobs) }
  let(:running_jobs) { ['running job fetcher result'] }

  let(:result) do
    [
      'enqueued job fetcher result',
      'sorted entry type job fetcher result, call 1',
      'sorted entry type job fetcher result, call 2',
      'sorted entry type job fetcher result, call 3',
      'running job fetcher result'
    ]
  end

  before do
    allow(SidekiqSearch::Parameters).to receive(:new).and_return(parameters_validation_service)

    allow(SidekiqSearch::Fetchers::Enqueued).to receive(:new).and_return(enqueued_jobs_fetcher)

    allow(SidekiqSearch::Fetchers::SortedEntry).to receive(:new).and_return(sorted_entry_type_jobs_fetcher)
    allow(sorted_entry_type_jobs_fetcher).to receive(:call).and_return(
      ['sorted entry type job fetcher result, call 1'],
      ['sorted entry type job fetcher result, call 2'],
      ['sorted entry type job fetcher result, call 3']
    )

    allow(SidekiqSearch::Fetchers::Running).to receive(:new).and_return(running_jobs_fetcher)
  end

  it 'calls SidekiqSearch::Parameters to validate and format parameters' do
    perform

    expect(parameters_validation_service).to have_received(:call!).with(input_parameters)
  end

  it 'calls fetcher services and adds their return values to the result', :aggregate_failures do
    expect(perform).to eq(result)

    expect(enqueued_jobs_fetcher).to have_received(:call)

    expect(sorted_entry_type_jobs_fetcher).to have_received(:call).with(
      from_queues:,
      set_class: Sidekiq::ScheduledSet,
      set_category: 'scheduled'
    )

    expect(sorted_entry_type_jobs_fetcher).to have_received(:call).with(
      from_queues:,
      set_class: Sidekiq::RetrySet,
      set_category: 'retried'
    )

    expect(sorted_entry_type_jobs_fetcher).to have_received(:call).with(
      from_queues:,
      set_class: Sidekiq::DeadSet,
      set_category: 'dead'
    )

    expect(running_jobs_fetcher).to have_received(:call)
  end
end
