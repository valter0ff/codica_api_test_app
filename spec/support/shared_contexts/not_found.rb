# frozen_string_literal: true

RSpec.shared_context 'not found' do
  context 'when record not found' do
    let(:id) { 0 }

    run_test! do
      expect(response).to be_not_found
    end
  end
end
