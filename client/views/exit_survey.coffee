Template.exitsurvey.shouldDisable = ->
  if $("input:radio[name=strategy]:checked").val() is "others"
    return ""
  else
    return "disabled"