# frozen_string_literal: true

RSpec.describe 'Api::V1::Tasks', type: :request do
  let(:'X-User-Email') { current_user.email }
  let(:'X-User-Token') { current_user.authentication_token }
  let(:current_user) { create(:user) }
  let(:project) { create(:project, :with_tasks, user: current_user) }
  let(:project_id) { project.id }

  path '/api/v1/projects/{project_id}/tasks' do
    let(:task_ids) { nil }

    get 'Current user projects index' do
      tags 'Tasks'
      consumes 'application/vnd.api+json'
      produces 'application/vnd.api+json'
      parameter name: :'X-User-Email', in: :header, type: :string, description: 'User email'
      parameter name: :'X-User-Token', in: :header, type: :string, description: 'Access token'
      parameter name: :project_id, in: :path, schema: { type: :integer, description: 'Project id' }
      parameter name: :task_ids, in: :query, explode: false, schema: {
        items: { type: :integer, description: 'Task id' }, type: :array
      }, required: false

      response(200, 'Success') do
        context 'without filter by ids' do
          run_test! do
            expect(response).to be_ok
            expect(response).to match_json_schema('tasks/index')
          end
        end

        context 'with filter by ids' do
          let(:task_1) { create(:task, project:) }
          let(:task_2) { create(:task, project:) }
          let(:task_ids) { [task_1.id, task_2.id] }

          run_test! do
            expect(response).to be_ok
            expect(response).to match_json_schema('tasks/index')

            parsed_response = JSON.parse(response.body, symbolize_names: true)
            expect(parsed_response[:data].map { |task| task[:id] }).to match_array(task_ids.map(&:to_s))
          end
        end
      end

      response(401, 'Invalid token') do
        include_context 'unauthenticated'
      end
    end

    post 'Create task' do
      tags 'Tasks'
      consumes 'application/vnd.api+json'
      produces 'application/vnd.api+json'
      parameter name: :'X-User-Email', in: :header, type: :string, description: 'User email'
      parameter name: :'X-User-Token', in: :header, type: :string, description: 'Access token'
      parameter name: :project_id, in: :path, schema: { type: :integer, description: 'Project id' }
      parameter name: :params, in: :body, schema: {
        type: :object,
        required: %w[task],
        properties: {
          title: { type: :string, description: 'Task title' },
          description: { type: :string, description: 'Task description' },
          status: { type: :string, enum: Task.statuses.keys, description: 'Task status' }
        }
      }

      let(:params) { { task: { title:, description: } } }
      let(:title) { 'Cool task' }
      let(:description) { 'Cool task' }

      response(201, 'Task is created') do
        run_test! do
          expect(response).to be_created
          expect(response).to match_json_schema('tasks/show')
          expect(Task.last).to have_attributes(title:, description:)
        end
      end

      response(422, 'Invalid parameters') do
        context 'when title is invalid' do
          let(:title) { nil }

          run_test! do
            expect(response).to be_unprocessable
            expect(response).to match_json_schema('tasks/errors')
          end
        end

        context 'when status is invalid' do
          let(:status) { 'failed' }
          let(:params) { { task: { title:, status: } } }

          run_test! do
            expect(response).to be_unprocessable
            expect(response).to match_json_schema('tasks/errors')
          end
        end
      end

      response(401, 'Invalid token') do
        include_context 'unauthenticated'
      end
    end
  end

  path '/api/v1/tasks/{id}' do
    subject(:api_request) { |example| submit_request(example.metadata) }

    let(:task) { create(:task, project:) }
    let(:id) { task.id }

    get 'Show task' do
      tags 'Tasks'
      consumes 'application/vnd.api+json'
      produces 'application/vnd.api+json'
      parameter name: :'X-User-Email', in: :header, type: :string, description: 'User email'
      parameter name: :'X-User-Token', in: :header, type: :string, description: 'Access token'
      parameter name: :id, in: :path, schema: { type: :integer, description: 'Task id' }

      response(200, 'Success') do
        run_test! do
          expect(response).to be_ok
          expect(response).to match_json_schema('tasks/show')
        end
      end

      response(401, 'Invalid token') do
        include_context 'unauthenticated'
      end

      response(404, 'Invalid task id') do
        include_context 'not found'
      end
    end

    put 'Update task' do
      tags 'Tasks'
      consumes 'application/vnd.api+json'
      produces 'application/vnd.api+json'
      parameter name: :'X-User-Email', in: :header, type: :string, description: 'User email'
      parameter name: :'X-User-Token', in: :header, type: :string, description: 'Access token'
      parameter name: :id, in: :path, schema: { type: :integer, description: 'Task id' }
      parameter name: :params, in: :body, schema: {
        type: :object,
        required: %w[task],
        properties: {
          title: { type: :string, description: 'Task title' },
          description: { type: :string, description: 'Task description' },
          status: { type: :string, enum: Task.statuses.keys, description: 'Task status' }
        }
      }

      let(:params) { { task: { title: } } }
      let(:title) { 'New title' }

      response(200, 'Task is updated') do
        it 'Updates task' do
          expect { api_request }.to change { task.reload.title }.to('New title')

          expect(response).to be_ok
          expect(response).to match_json_schema('tasks/show')
        end
      end

      response(401, 'Invalid token') do
        include_context 'unauthenticated'
      end

      response(404, 'Invalid task id') do
        include_context 'not found'
      end

      response(422, 'Project title already exists') do
        context 'when title is invalid' do
          let(:title) { nil }

          run_test! do
            expect(response).to be_unprocessable
            expect(response).to match_json_schema('tasks/errors')
          end
        end

        context 'when status is invalid' do
          let(:status) { 'failed' }
          let(:params) { { task: { title:, status: } } }

          run_test! do
            expect(response).to be_unprocessable
            expect(response).to match_json_schema('tasks/errors')
          end
        end
      end
    end

    delete 'Destroy task' do
      tags 'Tasks'
      consumes 'application/vnd.api+json'
      produces 'application/vnd.api+json'
      parameter name: :'X-User-Email', in: :header, type: :string, description: 'User email'
      parameter name: :'X-User-Token', in: :header, type: :string, description: 'Access token'
      parameter name: :id, in: :path, schema: { type: :integer, description: 'Task id' }

      response(204, 'Task is destroyed') do
        before { task }

        it 'Destroys project' do
          expect { api_request }.to change(Task, :count).by(-1)
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
