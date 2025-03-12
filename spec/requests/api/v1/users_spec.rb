# frozen_string_literal: true

RSpec.describe 'Api::V1::Users', type: :request do
  let(:current_user) { create(:user) }
  let(:'X-User-Email') { current_user.email }
  let(:'X-User-Token') { current_user.authentication_token }
  let(:include) { nil }

  path '/api/v1/users/show' do
    get 'Show user info' do
      tags 'User'
      consumes 'application/vnd.api+json'
      produces 'application/vnd.api+json'
      parameter name: :'X-User-Email', in: :header, type: :string, description: 'User email'
      parameter name: :'X-User-Token', in: :header, type: :string, description: 'Access token'
      parameter name: :include, in: :query, explode: false, schema: {
        items: { type: :string, enum: %w[projects projects.tasks] },
        type: :array
      }, required: false

      response(200, 'Success') do
        context 'without relationships' do
          run_test! do
            expect(response).to be_ok
            expect(response).to match_json_schema('users/show')
          end
        end

        context 'with relationships' do
          let(:current_user) do
            create(:user, :with_projects, projects_count: 1,
                                          project_params: [:with_tasks],
                                          project_options: { tasks_count: 1 })
          end
          let(:include) { %w[projects projects.tasks] }

          run_test! do
            expect(response).to be_ok
            expect(response).to match_json_schema('users/show_with_relationships')
          end
        end
      end

      response(401, 'Invalid token') do
        include_context 'unauthenticated'
      end
    end
  end
end
