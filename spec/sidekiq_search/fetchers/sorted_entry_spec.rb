# frozen_string_literal: true

require TEST_JOBS_ROOT.join('retry_set_job.rb')
require TEST_JOBS_ROOT.join('dead_set_job.rb')
require TEST_JOBS_ROOT.join('enqueued_fetcher_job.rb')

RSpec.describe SidekiqSearch::Fetchers::SortedEntry do
  let(:perform) { described_class.new.call(from_queues:, set_class:, set_category:) }

  let(:param) { SecureRandom.hex }
  let(:from_queues) { %w[default] }
  let(:result) { perform.first }

  before(:all) { SidekiqSearch::Util.flush_all } # rubocop:disable RSpec/BeforeAfterAll
  after { SidekiqSearch::Util.flush_all }

  before do
    sidekiq_job_id

    sleep(2)
  end

  context 'when set_category is retried' do
    let(:sidekiq_job_id) { RetrySetJob.perform_async(param) }

    let(:set_class) { Sidekiq::RetrySet }
    let(:set_category) { 'retried' }

    it 'gets the retried job', :aggregate_failures do
      expect(result[:job_object]).to be_a(Sidekiq::JobRecord)
      expect(result[:class]).to eq('RetrySetJob')
      expect(result[:arguments]).to eq([param])
      expect(result[:created_at]).to be_a(Time)
      expect(result[:enqueued_at]).to be_a(Time)
      expect(result[:queue_name]).to eq('default')
      expect(result[:sidekiq_job_id]).to eq(sidekiq_job_id)
      expect(result[:activejob_job_id]).to be_nil
      expect(result[:category]).to eq(set_category)
    end
  end

  context 'when set_category is dead' do
    let(:sidekiq_job_id) { DeadSetJob.perform_async(param) }

    let(:set_class) { Sidekiq::DeadSet }
    let(:set_category) { 'dead' }

    it 'gets the dead job', :aggregate_failures do
      expect(result[:job_object]).to be_a(Sidekiq::JobRecord)
      expect(result[:class]).to eq('DeadSetJob')
      expect(result[:arguments]).to eq([param])
      expect(result[:created_at]).to be_a(Time)
      expect(result[:enqueued_at]).to be_a(Time)
      expect(result[:queue_name]).to eq('default')
      expect(result[:sidekiq_job_id]).to eq(sidekiq_job_id)
      expect(result[:activejob_job_id]).to be_nil
      expect(result[:category]).to eq(set_category)
    end
  end

  context 'when set_category is scheduled' do
    let(:sidekiq_job_id) { EnqueuedFetcherJob.perform_in(600, param) }

    let(:from_queues) { %w[not_processed] }
    let(:set_class) { Sidekiq::ScheduledSet }
    let(:set_category) { 'scheduled' }

    it 'gets the scheduled job', :aggregate_failures do
      expect(result[:job_object]).to be_a(Sidekiq::JobRecord)
      expect(result[:class]).to eq('EnqueuedFetcherJob')
      expect(result[:arguments]).to eq([param])
      expect(result[:created_at]).to be_a(Time)
      expect(result[:enqueued_at]).to be_nil
      expect(result[:queue_name]).to eq('not_processed')
      expect(result[:sidekiq_job_id]).to eq(sidekiq_job_id)
      expect(result[:activejob_job_id]).to be_nil
      expect(result[:category]).to eq(set_category)
    end
  end
end
