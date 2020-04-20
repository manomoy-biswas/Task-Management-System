$(document).ready(function() {
  
  $(".add-fields").click(function(event){
    event.preventDefault();
      let time = new Date().getTime();
      let regexp = new RegExp($(this).data("id"), "g");
      $(this).after($(this).data("fields").replace(regexp, time));
  });

//  $("#priority").on("change", function() {
//      const value = $(this).val().toLowerCase();
//      $("#task_table tr").filter(function() {
//       $(this).toggle($(this).text().toLowerCase().indexOf(value) > -1)
//     });
//   });
});

$(document).on("click",".remove-field", function(event){
  event.preventDefault();
  $(this).prev("input[type=hidden]").val("1");
  $(this).closest('.subtask ').hide();
});