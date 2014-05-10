response_val = $("<%= j (render partial: 'shared/feed_item', locals: {feed_item: @micropost, show_gravatar: true }) %>")
response_val.hide();
$('ol.microposts').prepend(response_val)
response_val.fadeIn()
