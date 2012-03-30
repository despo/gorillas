class Building
  constructor:(context, color) ->
    @context = context
    @width = 200
    @height = 400
    @color = color

  draw:(x,y) ->
    @context.fillStyle = @color
    @height = @height - y
    @context.fillRect x, 600-@height, @width, @height
    @build_windows(x, y)

  build_windows:(x, y) ->
    height = 600 - @height
    @context.fillStyle = '#FFFF00'
    @context.fillRect x+z, height+y, 15, 30 for z in [ 35, 70, 105, 140, 175]

class Painter
  constructor: ->
    @canvas = document.getElementById "gorillas"
    @context = @canvas.getContext "2d"
    @color = '#00FFFF'

  draw_building:(x, y) ->
    building = new Building(@context, @color)
    building.draw(x, y)

  set_color:(color) ->
    @color = color

window.onload = ->
  painter = new Painter
  painter.draw_building(40, 20)
  painter.draw_building(245, 5)

  painter.set_color '#800000'
  painter.draw_building(450, 25)
  painter.draw_building(655, 15)
