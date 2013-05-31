$ ->
 window.setTimeout(CloseAlertDiv,4000)

this.CloseAlertDiv = -> 
 $('div.alert').fadeOut('slow')