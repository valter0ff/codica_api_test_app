# frozen_string_literal: true

RSpec.describe 'Api::V1::Registrations', type: :request do
  let(:email) { 'email@example.com' }
  let(:password) { '123456' }
  let(:params) { { user: { email:, password: } } }

  path '/api/v1/sign_up' do
    post 'Sign up user' do
      tags 'Registration'
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

      response(200, 'Success sign up') do
        it 'Creates user' do
          expect { api_request }.to change(User, :count).by(1)

          expect(response).to be_ok
          expect(response.parsed_body[:status][:code]).to eq(200)
          expect(response.parsed_body[:status][:message]).to eq('Signed up successfully.')
          expect(response).to match_json_schema('registrations/sign_up')

          expect(User.last).to have_attributes(email: email)
        end

        examples 'application/json' => response_schema('registrations/sign_up')
      end

      response(422, 'Invalid params') do
        context 'when invalid password' do
          let(:password) { '' }

          run_test! do
            expect(response).to be_unprocessable
            expect(response.parsed_body[:status][:code]).to eq(422)
            expect(response.parsed_body[:status][:message]).to eq("User couldn't be created. Password can't be blank")
            expect(response).to match_json_schema('registrations/errors')
          end

          examples 'application/json' => response_schema('registrations/errors')
        end

        context 'when user with particular email already exists' do
          before { create(:user, email:) }

          run_test! do
            expect(response).to be_unprocessable
            expect(response.parsed_body[:status][:code]).to eq(422)
            expect(response.parsed_body[:status][:message]).to eq(
              "User couldn't be created. Email has already been taken"
            )
            expect(response).to match_json_schema('registrations/errors')
          end

          examples 'application/json' => response_schema('registrations/errors')
        end
      end
    end
  end
end
