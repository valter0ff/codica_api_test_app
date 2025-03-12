# frozen_string_literal: true

RSpec.describe 'Api::V1::Projects', type: :request do
  let(:'X-User-Email') { current_user.email }
  let(:'X-User-Token') { current_user.authentication_token }
  let(:current_user) { create(:user, :with_projects) }
  let(:project) { create(:project, user: current_user) }
  let(:project_ids) { nil }
  let(:include) { nil }

  path '/api/v1/projects' do
    get 'Current user projects index' do
      tags 'Projects'
      consumes 'application/vnd.api+json'
      produces 'application/vnd.api+json'
      parameter name: :'X-User-Email', in: :header, type: :string, description: 'User email'
      parameter name: :'X-User-Token', in: :header, type: :string, description: 'Access token'
      parameter name: :include, in: :query, explode: false, schema: {
        items: { type: :string, enum: %w[tasks] }, type: :array
      }, required: false
      parameter name: :project_ids, in: :query, explode: false, schema: {
        items: { type: :integer, description: 'Project id' }, type: :array
      }, required: false

      response(200, 'Success') do
        context 'without relationships' do
          run_test! do
            expect(response).to be_ok
            expect(response).to match_json_schema('projects/index')
          end
        end

        context 'with relationships' do
          let(:current_user) do
            create(:user, :with_projects, projects_count: 1,
                                          project_params: [:with_tasks],
                                          project_options: { tasks_count: 1 })
          end
          let(:include) { %w[tasks] }

          run_test! do
            expect(response).to be_ok
            expect(response).to match_json_schema('projects/index_with_tasks')
          end
        end

        context 'with filter by ids' do
          let(:project_1) { create(:project, user: current_user) }
          let(:project_2) { create(:project, user: current_user) }
          let(:project_ids) { [project_1.id, project_2.id] }

          run_test! do
            expect(response).to be_ok
            expect(response).to match_json_schema('projects/index')

            parsed_response = JSON.parse(response.body, symbolize_names: true)
            expect(parsed_response[:data].map { |project| project[:id] }).to match_array(project_ids.map(&:to_s))
          end
        end
      end

      response(401, 'Invalid token') do
        include_context 'unauthenticated'
      end
    end

    post 'Create project' do
      tags 'Projects'
      consumes 'application/vnd.api+json'
      produces 'application/vnd.api+json'
      parameter name: :'X-User-Email', in: :header, type: :string, description: 'User email'
      parameter name: :'X-User-Token', in: :header, type: :string, description: 'Access token'
      parameter name: :params, in: :body, schema: {
        type: :object,
        required: %w[project],
        properties: {
          title: { type: :string, description: 'Project title' },
          description: { type: :string, description: 'Project description' }
        }
      }

      let(:params) { { project: { title:, description: } } }
      let(:title) { 'Cool project' }
      let(:description) { 'Cool description' }

      response(201, 'Project is created') do
        run_test! do
          expect(response).to be_created
          expect(response).to match_json_schema('projects/show')
          expect(Project.last).to have_attributes(title:, description:)
        end
      end

      response(422, 'Invalid parameters') do
        context 'when title is invalid' do
          let(:title) { nil }

          run_test! do
            expect(response).to be_unprocessable
            expect(response).to match_json_schema('projects/errors')
          end
        end

        context 'when project with provided title already exists' do
          let(:project) { create(:project, user: current_user) }
          let(:title) { project.title }

          run_test! do
            expect(response).to be_unprocessable
            expect(response).to match_json_schema('projects/errors')
          end
        end
      end

      response(401, 'Invalid token') do
        include_context 'unauthenticated'
      end
    end
  end

  path '/api/v1/projects/{id}' do
    subject(:api_request) { |example| submit_request(example.metadata) }

    get 'Show project' do
      tags 'Projects'
      consumes 'application/vnd.api+json'
      produces 'application/vnd.api+json'
      parameter name: :'X-User-Email', in: :header, type: :string, description: 'User email'
      parameter name: :'X-User-Token', in: :header, type: :string, description: 'Access token'
      parameter name: :id, in: :path, schema: { type: :integer, description: 'Project id' }
      parameter name: :include, in: :query, explode: false, schema: {
        items: { type: :string, enum: %w[tasks] }, type: :array
      }, required: false

      let(:id) { project.id }

      response(200, 'Success') do
        run_test! do
          expect(response).to be_ok
          expect(response).to match_json_schema('projects/show')
        end

        context 'with relationships' do
          let(:project) { create(:project, :with_tasks, user: current_user) }
          let(:include) { %w[tasks] }

          run_test! do
            expect(response).to be_ok
            expect(response).to match_json_schema('projects/show_with_tasks')
          end
        end
      end

      response(401, 'Invalid token') do
        include_context 'unauthenticated'
      end

      response(404, 'Invalid project id') do
        include_context 'not found'
      end
    end

    put 'Update project' do
      tags 'Projects'
      consumes 'application/vnd.api+json'
      produces 'application/vnd.api+json'
      parameter name: :'X-User-Email', in: :header, type: :string, description: 'User email'
      parameter name: :'X-User-Token', in: :header, type: :string, description: 'Access token'
      parameter name: :id, in: :path, schema: { type: :integer, description: 'Project id' }
      parameter name: :params, in: :body, schema: {
        type: :object,
        required: %w[project],
        properties: {
          title: { type: :string, description: 'Project title' },
          description: { type: :string, description: 'Project description' }
        }
      }

      let(:id) { project.id }
      let(:params) { { project: { title: } } }
      let(:title) { 'New title' }

      response(200, 'Project is updated') do
        it 'Updates project' do
          expect { api_request }.to change { project.reload.title }.to('New title')

          expect(response).to be_ok
          expect(response).to match_json_schema('projects/show')
        end
      end

      response(401, 'Invalid token') do
        include_context 'unauthenticated'
      end

      response(404, 'Invalid project id') do
        include_context 'not found'
      end

      response(422, 'Project title already exists') do
        let(:another_project) { create(:project, user: current_user) }
        let(:title) { another_project.title }

        run_test! do
          expect(response).to be_unprocessable
          expect(response).to match_json_schema('projects/errors')
        end
      end
    end

    delete 'Destroy project' do
      tags 'Projects'
      consumes 'application/vnd.api+json'
      produces 'application/vnd.api+json'
      parameter name: :'X-User-Email', in: :header, type: :string, description: 'User email'
      parameter name: :'X-User-Token', in: :header, type: :string, description: 'Access token'
      parameter name: :id, in: :path, schema: { type: :integer, description: 'Project id' }

      let(:id) { project.id }

      response(204, 'Project is destroyed') do
        let(:current_user) { create(:user) }

        before { project }

        it 'Destroys project' do
          expect { api_request }.to change(Project, :count).by(-1)
          expect(response).to be_no_content
        end
      end

      response(401, 'Invalid token') do
        include_context 'unauthenticated'
      end

      response(404, 'Invalid project id') do
        include_context 'not found'
      end
    end
  end
end
