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
    events = Task.pending.each_with_object([]) do |t, acc|
      prev_user_id = t.assigned_to_id
      t.update!(assigned_to: fetch_account_to_assign)
      event = {
        **task_event_data,
        event_name: 'Task.Assigned',
        data: {
          public_id: t.public_id,
          assigned_to: {
            public_id: t.assigned_to.public_id
          }
        }
      }
      acc << {topic: 'tasks', payload: event.to_json} if prev_user_id != t.assigned_to_id
    end
    KAFKA_PRODUCER.produce_many_sync(events)
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

    respond_to do |format|
      if @task.save
        data = task_data(@task)
        KAFKA_PRODUCER.produce_many_sync(
          [
            {topic: 'tasks-stream', payload: {**task_event_data, event_name: 'Task.Created', data: data}.to_json},
            {topic: 'tasks', payload: {**task_event_data, event_name: 'Task.Added', data: data}.to_json}
          ]
        )

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
        data = task_data(@task)
        events = []

        events << {topic: 'tasks-stream', payload: {**task_event_data, event_name: 'Task.Updated', data: data}.to_json}
        if @task.previous_changes.has_key?('state') && @task.resolved?
          payload = {
            public_id: @task.public_id,
            assigned_to: {
              public_id: @task.assigned_to.public_id
            }
          }
          events << {topic: 'tasks', payload: {**task_event_data, event_name: 'Task.Resolved', data: payload}.to_json}
        end

        KAFKA_PRODUCER.produce_many_sync(events)
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
      params.require(:task).permit(:public_id, :state, :assigned_to_id, :created_by_id, :title, :description)
    end

    def fetch_account_to_assign
      Account.executors.random.take
    end

    def task_event_data
      {
        event_id: SecureRandom.uuid,
        event_version: 1,
        event_time: Time.now.to_s,
        producer: 'task_manager',
      }
    end

    def task_data(task)
      {
        public_id: task.public_id,
        title: task.title,
        state: task.state,
        description: task.description,
        assigned_to: {
          public_id: task.assigned_to.public_id
        },
        created_by: {
          public_id: task.created_by.public_id
        }
      }
    end
end
