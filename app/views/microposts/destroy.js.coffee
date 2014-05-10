# $("li##{micropost.id}").remove()
$('a.delete_micropost').bind('ajax:success', -> 
  $(this).closest("li").fadeOut() #Is this the fastes approach?  Check jsperf
  )