# frozen_string_literal: true

class Api::V1::TasksController < ApplicationController
  before_action :set_project, only: %i[index create]
  before_action :set_task, only: %i[show update destroy]

  def index
    tasks = @project.tasks
    tasks.where!(status: params[:status]) if params[:status].present?

    if params[:task_ids].present?
      task_ids = params[:task_ids].is_a?(String) ? params[:task_ids].split(',') : params[:task_ids]
      tasks = tasks.where(id: task_ids.map(&:to_i))
    end

    render jsonapi: tasks
  end

  def show
    render jsonapi: @task
  end

  def create
    task = @project.tasks.build(task_params)
    if task.save
      render jsonapi: task, status: :created
    else
      render jsonapi_errors: task.errors, status: :unprocessable_entity
    end
  end

  def update
    if @task.update(task_params)
      render jsonapi: @task
    else
      render jsonapi_errors: @task.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @task.destroy!
    head :no_content
  end

  private

  def set_project
    @project = current_user.projects.find_by(id: params[:project_id])
    head :not_found unless @project
  end

  def set_task
    @task = current_user.tasks.find_by(id: params[:id])
    head :not_found unless @task
  end

  def task_params
    params.require(:task).permit(:title, :description, :status)
  end
end
