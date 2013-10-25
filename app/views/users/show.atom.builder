atom_feed do |feed|
  feed.title "Posts by #{@user.name}"
  feed.updated @user.microposts.first.created_at
  @user.microposts.each do |micropost|
    feed.entry micropost, url: user_url(@user) do |entry|
       entry.content micropost.content
       entry.author micropost.user.username
    end
   end
end