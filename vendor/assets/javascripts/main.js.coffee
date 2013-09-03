$ ->
 window.setTimeout(CloseAlertDiv,8000)

this.CloseAlertDiv = -> 
 $('div.alert').fadeOut('slow')