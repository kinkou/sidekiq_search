# frozen_string_literal: true

require TEST_JOBS_ROOT.join('enqueued_fetcher_job.rb')

RSpec.describe SidekiqSearch::Fetchers::Enqueued do
  let(:perform) { described_class.new.call(from_queues:) }
  let(:param) { SecureRandom.hex }
  let(:from_queues) { %w[not_processed] }
  let(:result) { perform.first }
  let(:sidekiq_job_id) { EnqueuedFetcherJob.perform_async(param) }

  before(:all) { SidekiqSearch::Util.flush_all } # rubocop:disable RSpec/BeforeAfterAll
  after { SidekiqSearch::Util.flush_all }

  before do
    sidekiq_job_id
  end

  it 'gets the enqueued job', :aggregate_failures do
    expect(result[:job_object]).to be_a(Sidekiq::JobRecord)
    expect(result[:class]).to eq('EnqueuedFetcherJob')
    expect(result[:arguments]).to eq([param])
    expect(result[:created_at]).to be_a(Time)
    expect(result[:enqueued_at]).to be_a(Time)
    expect(result[:queue_name]).to eq('not_processed')
    expect(result[:sidekiq_job_id]).to eq(sidekiq_job_id)
    expect(result[:activejob_job_id]).to be_nil
    expect(result[:category]).to eq('enqueued')
  end
end
