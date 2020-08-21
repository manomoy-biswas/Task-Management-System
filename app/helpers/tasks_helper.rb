module TasksHelper
  def link_to_add_subtask(name,f,association,**args)
    new_object = f.object.send(association).klass.new
    id = new_object.object_id
    fields = f.fields_for(association, new_object, child_index: id) do |builder|
      render(association.to_s.singularize, f: builder)
    end
    link_to(name, '#', class: 'add-fields ' + args[:class], data: {id: id, fields: fields.delete("\n")})
  end

  def user_list
    if current_user.admin
      User.all_user_except(current_user.id)
    elsif current_user.hr
      User.all_regular_and_hr_except(current_user.id)
    else
      User.all_employee_except(current_user.id)
    end
  end
end
