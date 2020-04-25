class TaskList < Prawn::Document
  def initialize(tasks)
    super()
    @tasks = tasks
    document_name
    line_items
  end

  def document_name
    text "TASK MANAGEMENT SYSTEM", size: 18, align: :center
    text "Approved Task List", size: 18, align: :center
  end

  def line_items
    move_down 20
    task_list
  end

  def task_list 
    table_header = [["Task Name", "Category", "Assigned To", "Assigned By", "Submit Date"]]
    table(table_header, header: true, column_widths: [125, 70, 130, 135, 80], cell_style:{ background_color:"000000", text_color: "ffffff", align: :center, border_color: "ffffff"} )
    if @tasks.present?
      data = []
      @tasks.each do |task|
        data += [["#{task.task_name}", "#{task.category.name}", "#{task.user.name} (id: #{task.assign_task_to} )", "#{User.find(task.assign_task_by).name} (id: #{task.assign_task_by} )","#{DateTime.parse(task.submit_date.to_s).strftime("%d-%m-%Y %I:%M %p")}"]]
      end
      table(data, column_widths: [125, 70, 130, 135, 80], row_colors: ["DDDDDD","FFFFFF"])
    end
  end

end
