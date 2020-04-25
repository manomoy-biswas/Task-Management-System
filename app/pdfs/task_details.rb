class TaskDetails < Prawn::Document
  def initialize(task)
    super()
    @task = task
    document_name
    line_items
  end

  def document_name
    text "TASK MANAGEMENT SYSTEM", size: 20, align: :center
    text "Task Details : #{@task.task_name}", size: 18, align: :center, text_style: :bold
    float{text "Task id: #{@task.id}", size: 14, align: :left}
    text "Date: #{Date.today.strftime("%d-%m-%Y")}", size: 14, align: :right
    move_down 20
    float{text "Category: #{@task.category.name}", size: 12, align: :left}
    float{text "Priority: #{@task.priority}", size: 12, align: :center}
    text "Deadline: #{DateTime.parse(@task.submit_date.to_s).strftime("%d-%m-%Y")}", size: 14, align: :right
  end

  def line_items
    move_down 10
    task_details
  end

  def task_details
    text "Task Name: #{@task.task_name}"
    text "Description: #{@task.description}"
    move_down 20
    if @task.sub_task.present?
      i=0
      @task.sub_task.each do |subtask|
        text "Sub Task: #{i=i+1}", size: 14, text_color: "FF0000"
        text "Task Name: #{subtask.name}"
        text "Description: #{subtask.subtask_description}"
      end
      move_down 20
    end
    float{ text "Assign To: #{@task.user.name}", align: :left}
    text "Assign By: #{User.find(@task.assign_task_by).name}", align: :right
  end
end