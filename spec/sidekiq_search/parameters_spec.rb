# frozen_string_literal: true

RSpec.describe SidekiqSearch::Parameters do
  let(:perform) { described_class.new.call!(from_categories:, from_queues:) }

  let(:from_categories) { ['scheduled'] }
  let(:from_queues) { ['default'] }

  let(:result) { { from_categories: ['scheduled'], from_queues: ['default'] } }

  describe 'from_categories parameter' do
    context 'when array' do
      it 'is handled normally' do
        expect(perform).to eq(result)
      end
    end

    context 'when single value' do
      let(:from_categories) { 'scheduled' }

      it 'is handled normally' do
        expect(perform).to eq(result)
      end
    end

    context 'when empty' do
      let(:from_categories) { [] }

      it 'raises ArgumentError' do
        expect { perform }.to raise_error(ArgumentError, /must contain at least one category name/)
      end
    end

    context 'when unknown' do
      let(:from_categories) { [nil, '', %w[scheduled foo]].sample }

      it 'raises ArgumentError' do
        expect { perform }.to raise_error(ArgumentError, /Unknown category/)
      end
    end
  end

  describe 'from_queues parameter' do
    context 'when array' do
      it 'is handled normally' do
        expect(perform).to eq(result)
      end
    end

    context 'when single value' do
      let(:from_queues) { 'default' }

      it 'is handled normally' do
        expect(perform).to eq(result)
      end
    end

    context 'when empty' do
      let(:from_queues) { [] }

      it 'raises ArgumentError' do
        expect { perform }.to raise_error(ArgumentError, /must contain at least one queue name/)
      end
    end
  end
end
