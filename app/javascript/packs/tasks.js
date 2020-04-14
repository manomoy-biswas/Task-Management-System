$(document).ready(function() {
  
  $(".add-fields").click(function(event){
    event.preventDefault();
    time = new Date().getTime();
    regexp = new RegExp($(this).data("id"), "g");
    $(this).before($(this).data("fields").replace(regexp, time)).html(z);
  });

 $("#priority").on("change", function() {
    var value = $(this).val().toLowerCase();
    $("#task_table tr").filter(function() {
      $(this).toggle($(this).text().toLowerCase().indexOf(value) > -1)
    });
  });
});

$(document).on("click",".remove-field", function(event){
  event.preventDefault();
  $(this).prev("input[type=hidden]").val("1");
  $(this).closest('.subtask ').hide();
});

$(document).ready(function(){
  
});