module TasksHelper
  def link_to_add_subtask(name,f,association,**args)
    new_object = f.object.send(association).klass.new
    id = new_object.object_id
    fields = f.fields_for(association, new_object, child_index: id) do |builder|
      render(association.to_s.singularize, f: builder)
    end
    link_to(name, '#', class: 'add-fields ' + args[:class], data: {id: id, fields: fields.delete("\n")})
  end

  def find_task(task_id)
    Task.find_by(id: task_id)
  end
  
  def find_user_name(user_id)
      User.find(user_id).name
  end
end
