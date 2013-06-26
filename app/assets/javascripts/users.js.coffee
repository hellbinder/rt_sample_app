# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  a = '<form accept-charset="UTF-8" action="/microposts" class="new_micropost" id="reply_micropost" method="post"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="✓"><input name="authenticity_token" type="hidden" value="CrLj4duoYOy22vzVL5vLACZXl0n5bthK/w9Uw7YlOrg="></div>  
              <div class="field">
                <textarea cols="40" id="micropost_content" class="micropost_text" name="micropost[content]" placeholder="Compose new micropost..." rows="20"></textarea>
                <p class="text-right" id="counter">140</p>
                <input class="btn btn-large btn-primary" data-disable-with="Posting..." name="commit" type="submit" value="Post"></input>
                <input class="hiddenReplyTo" type="hidden" name="micropost[in_reply_to]"/>
              </div>
            </form>'
  $("a.reply_to").click (s) ->
    $("form.reply_micropost").remove()
    console.log $(this).closest("li").attr("id")
    $(this).closest("li").append(a)
    mp_id = $(this).closest("li").attr("id")
    $(".hiddenReplyTo").val(mp_id)

