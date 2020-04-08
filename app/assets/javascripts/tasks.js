$(document).ready(function() {
  
  $(".add-fields").click(function(event){
    event.preventDefault();
    time = new Date().getTime();
    regexp = new RegExp($(this).data("id"), "g");
    $(this).before($(this).data("fields").replace(regexp, time)).html(z);
  });
});

$(document).on("click",".remove-field", function(event){
  event.preventDefault();
  $(this).prev("input[type=hidden]").val("1");
  $(this).closest('.subtask ').hide();
});