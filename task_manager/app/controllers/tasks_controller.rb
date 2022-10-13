class TasksController < ApplicationController
  before_action :require_user_logged_in!
  before_action :set_task, only: %i[ show edit update ]

  # GET /tasks or /tasks.json
  def index
    @tasks = Task.all.preload(:assigned_to, :created_by).order(:id)
  end

  def my
    @tasks = Task.where(assigned_to: current_account).all.preload(:assigned_to, :created_by).order(:id)
  end

  def shuffle
    Task.pending.each do |t|
      t.update!(assigned_to: fetch_account_to_assign)
    end

    redirect_to '/tasks'
  end

  # GET /tasks/1 or /tasks/1.json
  def show
  end

  # GET /tasks/new
  def new
    @task = Task.new
  end

  # GET /tasks/1/edit
  def edit
  end

  # POST /tasks or /tasks.json
  def create
    @task = Task.new(**task_params)
    @task.created_by = current_account
    @task.assigned_to = fetch_account_to_assign
    console
    respond_to do |format|
      if @task.save
        format.html { redirect_to task_url(@task), notice: "Task was successfully created." }
        format.json { render :show, status: :created, location: @task }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tasks/1 or /tasks/1.json
  def update
    respond_to do |format|
      if @task.update(task_params)
        format.html { redirect_to task_url(@task), notice: "Task was successfully updated." }
        format.json { render :show, status: :ok, location: @task }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_task
      @task = Task.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def task_params
      params.require(:task).permit(:public_id, :status, :assigned_to_id, :created_by_id, :title, :description)
    end

    def fetch_account_to_assign
      Account.executors.random.take
    end
end
