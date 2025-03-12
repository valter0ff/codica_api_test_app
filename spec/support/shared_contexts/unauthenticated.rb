# frozen_string_literal: true

RSpec.shared_context 'unauthenticated' do
  context 'when unauthenticated' do
    let(:'X-User-Token') { nil }

    run_test! do
      expect(response).to be_unauthorized
      expect(response.parsed_body[:error]).to eq('You need to sign in or sign up before continuing.')
      expect(response).to match_json_schema('sessions/unauthorized')
    end
  end
end
