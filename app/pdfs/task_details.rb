class TaskDetails < Prawn::Document
  def initialize(task)
    super()
    @task = task
    document_name
    line_items
  end

  def document_name
    text "TASK MANAGEMENT SYSTEM", size: 20, align: :center
    move_down 10
    text "Task Details : #{@task.task_name}", size: 18, align: :center, text_style: :bold
    move_down 20
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
    text "Task Name:", color: "0b64e8"
    move_down 10
    text "#{@task.task_name}"
    move_down 10
    text "Description:",color: "0b64e8"
    move_down 10
    text "#{@task.description}"
    move_down 10
    if @task.sub_task.present?
      i=0
      @task.sub_task.each do |subtask|
        text "Sub Task: #{i=i+1}", size: 10, color: "FF0000"
        move_down 5
        text "Task Name:", color: "0b64e8"
        move_down 2
        text "#{subtask.name}"
        move_down 10
        text "Description:", color: "0b64e8"
        move_down 5
        text "#{subtask.subtask_description}"
      end
      move_down 20
    end
    move_down 20
    float{ text "Assign To: #{@task.user.name}", align: :left}
    text "Assign By: #{User.find(@task.assign_task_by).name}", align: :right
  end
end