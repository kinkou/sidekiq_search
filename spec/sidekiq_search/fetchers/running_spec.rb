# frozen_string_literal: true

require TEST_JOBS_ROOT.join('running_fetcher_job.rb')

RSpec.describe SidekiqSearch::Fetchers::Running do
  let(:perform) { described_class.new.call(from_queues:) }
  let(:sleep_for) { 20 }
  let(:from_queues) { %w[default] }
  let(:result) { perform.first }
  let(:sidekiq_job_id) { RunningFetcherJob.perform_async(sleep_for) }

  before(:all) { SidekiqSearch::Util.flush_all } # rubocop:disable RSpec/BeforeAfterAll
  after { SidekiqSearch::Util.flush_all }

  before { sidekiq_job_id }

  it 'gets the running job', :aggregate_failures do
    sleep(10)

    expect(result[:job_object]).to be_a(Sidekiq::JobRecord)
    expect(result[:class]).to eq('RunningFetcherJob')
    expect(result[:arguments]).to eq([sleep_for])
    expect(result[:created_at]).to be_a(Time)
    expect(result[:enqueued_at]).to be_a(Time)
    expect(result[:queue_name]).to eq('default')
    expect(result[:sidekiq_job_id]).to eq(sidekiq_job_id)
    expect(result[:activejob_job_id]).to be_nil
    expect(result[:category]).to eq('running')
    expect(result[:work_object]).to be_a(Sidekiq::Work)
  end
end
