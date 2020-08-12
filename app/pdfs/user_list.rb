class UserList < Prawn::Document
  def initialize(users)
    super()
    @users = users
    document_name
    line_items
  end

  def document_name
    text "TASK MANAGEMENT SYSTEM", size: 18, align: :center
    text "Users List", size: 18, align: :center
  end

  def line_items
    move_down 20
    user_list
  end

  def user_list 
    table_header = [["SL.No","Name", "Email", "Phone No", "Role"]]
    table(table_header, header: true, column_widths: [40, 150, 210, 80, 60], cell_style:{ size: 10, background_color:"000000", text_color: "ffffff", align: :center, border_color: "ffffff", size: 10} )
    if @users.present?
      data = []
      i = 0
      @users.each do |user|
        role =  if user.admin 
                  "Admin"
                elsif user.hr
                  "HR"
                else
                  "Employee"
                end
        data += [["#{i=i+1}","#{user.name}", "#{user.email}", "#{user.phone}", "#{role}"]]
      end
      table(data, column_widths: [40, 150, 210, 80, 60], row_colors: ["DDDDDD","FFFFFF"],cell_style: {size: 9})
    end
  end
end