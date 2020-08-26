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
    text "Task Details", size: 18, align: :center, text_style: :bold
    move_down 20
    text "#{@task.task_name}", size: 16, align: :center
    move_down 10
    float{text "Category: #{@task.category.name}", size: 12, align: :left}
    text "Priority: #{@task.priority}", size: 12, align: :right
    move_down 20
    float{text "Asign date: #{DateTime.parse(@task.submit_date.to_s).strftime("%d-%m-%Y - %I:%M %p")}", size: 14, align: :left}
    text "Deadline: #{DateTime.parse(@task.submit_date.to_s).strftime("%d-%m-%Y")}", size: 14, align: :right
  end

  def line_items
    move_down 10
    task_details
  end

  def task_details
    task_name = [["Task name", @task.task_name]]
    table(task_name, column_widths: [125, 415])
    move_down 10
    description = [["Task Description", @task.description]]
    table(description, column_widths: [125, 415])
    move_down 10
    if @task.sub_task.present?
      i=0
      @task.sub_task.each do |subtask|
        text "Sub Task: #{i=i+1}", size: 10, color: "FF0000"
        move_down 5
        subtask_name = [["Subtask name", subtask.name]]
        table(subtask_name, column_widths: [125, 415])
        move_down 10
        description = [["Subtask Description", subtask.subtask_description]]
        table(description, column_widths: [125, 415])
      end
      move_down 20
    end
    move_down 20
    float{ text "Assign To: #{@task.user.name}", align: :left}
    text "Assign By: #{User.find(@task.assign_task_by).name}", align: :right
    move_down 10
    if @task.approved
      text "Status: Approved", align: :left, color: "5EEC12"
    elsif @task.submit && !@task.approved
      text "Status: Submitted", align: :left, color: "ECDE12"
    else
      text "Status: In Progress", align: :left, color: "EC3812"
    end
  end
end