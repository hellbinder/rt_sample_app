# Article that helped me out figuring page specific javascript is 
#http://brandonhilkert.com/blog/page-specific-javascript-in-rails/
max_val = "";
$(".teststatic_pages.home, .testusers.show").ready ->
  max_val = $("#counter").html()
  GetRemainingCharacters()
  $("a.reply_to").on("click", (event) ->
      $("div.replyform").html("")
      targetId = $(event.target).parent().parent().parent().attr("id")
      $("div#reply_#{targetId}").html("Loading...")
      return
      )

  $(document).on("keyup", ".micropost_form", (event) ->
    GetRemainingCharacters(event.target)
    )
  return

GetRemainingCharacters = (target) ->
  if(target)
    current_length = $(target).val().length
    remaining_chars = max_val - current_length
    $counter =  $(target).parent().find('#counter')
    $counter.html(remaining_chars)
    return