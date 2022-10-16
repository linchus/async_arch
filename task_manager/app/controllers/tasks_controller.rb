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
      if prev_user_id != t.assigned_to_id
        payload = {
          public_id: t.public_id,
          assigned_to: {public_id: t.assigned_to.public_id}
        }
        acc << build_event('tasks-stream', 'Task.Updated', meta: task_event_data, payload: task_data(t))
        acc << build_event('tasks', 'Task.Assigned', meta: task_event_data(1), payload: payload)
      end
    end.compact
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
        payload = task_data(@task)
        KAFKA_PRODUCER.produce_many_sync(
          [
            build_event('tasks-stream', 'Task.Created', meta: task_event_data, payload: payload),
            build_event('tasks', 'Task.Added', meta: task_event_data, payload: payload)
          ].compact
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
        events = [
          build_event('tasks-stream', 'Task.Updated', meta: task_event_data, payload: task_data(@task))
        ]

        if @task.previous_changes.has_key?('state') && @task.resolved?
          payload = {
            public_id: @task.public_id,
            assigned_to: {public_id: @task.assigned_to.public_id}
          }
          events << build_event('tasks', 'Task.Resolved', meta: task_event_data(1), payload: payload)
        end

        KAFKA_PRODUCER.produce_many_sync(events.compact)
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

    def task_event_data(v = 2)
      {
        event_id: SecureRandom.uuid,
        event_version: v,
        event_time: Time.now.to_s,
        producer: 'task_manager',
      }
    end

    def task_data(task, version=2)
      case version
      when 1
        {
          public_id: task.public_id,
          title: task.old_title,
          state: task.state,
          description: task.description,
          assigned_to: {
            public_id: task.assigned_to.public_id
          },
          created_by: {
            public_id: task.created_by.public_id
          }
        }
      when 2
        {
          public_id: task.public_id,
          title: task.title,
          jira_id: task.jira_id,
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

    def build_event(topic, event_name, meta:, payload:)
      event = {
        **meta,
        event_name: event_name,
        data: payload
      }

      result = SchemaRegistry.validate_event(event, event_name.underscore, version: event[:event_version])

      if result.success?
        {topic: topic, payload: event.to_json}
      else
        puts "Event validation error: #{result.failure}"
        puts "Event data: #{event.inspect}"
      end
    end
end
