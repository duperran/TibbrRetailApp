module ItemsHelper
  
  def remove_link_unless_new_record(fields)
    unless fields.object.new_record?
     # out = ''
      out = fields.hidden_field(:_destroy)
      out << link_to_function("remove", " $(this).previous().value = '1'")
      out
    end
  end
  
  # These use the current date, but they could be lots easier.
  # Maybe just keep a global counter which starts at 10 or so.
  # That would be good enough if we only build 1 new record in the controller.
  #
  # And this of course is only needed because Ryan's example uses JS to add new
  # records. If you just build a new one in the controller this is all unnecessary.
  
  def add_task_link(name, form)
    link_to_function name do |page|
      task = render(:partial => 'picture', :locals => { :pf => form, :task => Picture.new })
      page << %{
        var new_task_id = "new_" + new Date().getTime();
        $('tasks').insert({ bottom: "#{ escape_javascript task }".replace(/new_\\d+/g, new_task_id) });
      }
    end
  end
  

end
