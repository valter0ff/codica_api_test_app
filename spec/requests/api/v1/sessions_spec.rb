# frozen_string_literal: true

RSpec.describe 'Api::V1::Sessions', type: :request do
  let(:current_user) { create(:user) }
  let(:'X-User-Email') { current_user.email }
  let(:'X-User-Token') { current_user.authentication_token }
  let(:params) { {} }

  path '/api/v1/sign_in' do
    post 'Login user' do
      tags 'Session'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string, description: 'User`s email' },
          password: { type: :string, description: 'User`s password' }
        },
        required: %w[email password]
      }

      subject(:api_request) { |example| submit_request(example.metadata) }

      response(200, 'Success login') do
        let(:params) { { user: { email: current_user.email, password: current_user.password } } }

        before { current_user.update_column(:authentication_token, nil) } # rubocop:disable Rails/SkipsModelValidations

        it 'Updates user`s authentication_token and returns it' do
          expect { api_request }.to change { current_user.reload.authentication_token }.from(nil)

          expect(response).to be_ok
          expect(response.parsed_body[:status][:code]).to eq(200)
          expect(response.parsed_body[:status][:message]).to eq('Logged in successfully.')
          expect(response).to match_json_schema('sessions/sign_in')
        end
      end

      response(401, 'Invalid params') do
        context 'with invalid password' do
          let(:params) { { user: { email: current_user.email, password: 'zzz' } } }

          run_test! do
            expect(response).to be_unauthorized
            expect(response.parsed_body[:error]).to eq('Invalid Email or password.')
            expect(response).to match_json_schema('sessions/unauthorized')
          end
        end

        include_context 'unauthenticated'
      end
    end
  end

  path '/api/v1/sign_out' do
    delete 'Logout user' do
      tags 'Session'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :'X-User-Email', in: :header, type: :string, description: 'User email'
      parameter name: :'X-User-Token', in: :header, type: :string, description: 'Access token'

      response(200, 'Success logout') do
        run_test! do
          expect(response).to be_ok
          expect(response.parsed_body[:status][:code]).to eq(200)
          expect(response.parsed_body[:status][:message]).to eq('Logged out successfully.')
          expect(response).to match_json_schema('sessions/sign_out')
        end
      end

      response(401, 'Invalid token') do
        let(:'X-User-Token') { nil }

        run_test! do
          expect(response).to be_unauthorized
          expect(response.parsed_body[:status][:code]).to eq(401)
          expect(response.parsed_body[:status][:message]).to eq('User not found or already logged out.')
          expect(response).to match_json_schema('sessions/sign_out')
        end
      end
    end
  end
end
