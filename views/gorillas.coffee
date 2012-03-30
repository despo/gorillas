class Building
  constructor:(context, color) ->
    @context = context
    @width = 100
    @height = 150
    @color = color

  draw:(x,y) ->
    @context.fillStyle = @color
    @height = @height + y - 20
    @context.fillRect x, 640-@height, @width, @height
    @build_windows(x, y)

  build_windows:(x, y) ->
    height = 600 - @height + y
    times = Math.round((@height)/46)
    console.log times
    windows = [ 10, 25, 40, 55, 70, 85 ]
    current_distance = 30
    total_height = 0
    @context.fillStyle = '#FFFF00'
    row = 0
    loop
      total_height += current_distance
      @create_window x+z, 625+total_height-@height for z in windows
      break if row>times
      row++

  create_window:(x, y) ->
    @context.fillRect x, y, 8, 16


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
  painter.draw_building(40, 130)
  painter.draw_building(142, 90)

  painter.set_color '#800000'
  painter.draw_building(244, 150)
  painter.draw_building(346, 140)
  painter.draw_building(448, 80)

  painter.set_color '#C0C0C0'
  painter.draw_building(550, 0)

  painter.set_color '#800000'
  painter.draw_building(652, 200)

  painter.set_color '#C0C0C0'
  painter.draw_building(754, 40)

  painter.set_color '#800000'
  painter.draw_building(856, 30)
  painter.draw_building(958, -15)
