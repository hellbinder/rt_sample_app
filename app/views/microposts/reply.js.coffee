# HOW CAN I USE HAML HERE! 
#CHECK rails server logs to find out when javascript fails!
micropost_reply_id = "<%= @reply_to_micropost.id %>"
$replyDiv = $("#reply_" + micropost_reply_id)
$replyDiv.html("<%= j (render partial: 'shared/micropost_form', locals: { in_reply_to: @reply_to_micropost.id } ) %>")
$replyDiv.find("form textarea").focus()