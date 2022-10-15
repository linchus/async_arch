json.extract! task, :id, :public_id, :state, :assigned_to_id, :created_by_id, :title, :description, :created_at, :updated_at
json.url task_url(task, format: :json)
