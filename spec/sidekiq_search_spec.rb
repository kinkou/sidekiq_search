# frozen_string_literal: true

RSpec.describe SidekiqSearch do
  it 'has a version number' do
    expect(described_class::VERSION).not_to be_nil
  end

  describe '.jobs' do
    let(:perform) { described_class.jobs(from_categories:, from_queues:) }

    let(:service_class) { described_class::Jobs }
    let(:service_instance) { instance_double(service_class, call: nil) }

    let(:from_categories) { ['scheduled'] }
    let(:from_queues) { ['default'] }

    before do
      allow(service_class).to receive(:new).and_return(service_instance)
    end

    specify do
      perform

      expect(service_instance).to have_received(:call).with(
        from_categories:,
        from_queues:
      )
    end
  end
end
