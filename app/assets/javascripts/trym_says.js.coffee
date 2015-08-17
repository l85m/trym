@trymSays = (index = 0, lines = $('.trym-fade-in:visible')) ->
  say = $(lines[index])
  
  say.animate {"opacity":1}, 1000, ->
    if index < lines.length
      trymSays(index+1, lines)
      
$ ->
  trymSays()
  return