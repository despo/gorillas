class Building
  constructor:(context, color) ->
    @context = context
    @width = 100
    @height = 135
    @color = color

  draw:(x,y) ->
    @context.fillStyle = @color
    @height = @height + y
    @context.fillRect x, 640-@height, @width, @height
    @build_windows(x, y)

  build_windows:(x, y) ->
    times = Math.round (@height)/31
    windows = [ 10, 25, 40, 55, 70, 85 ]
    current_distance = 30
    total_height = 30
    @context.fillStyle = '#FFFF00'
    row = 1
    loop
      break if times < row
      @create_window x+z, 620+total_height-@height for z in windows
      total_height += current_distance
      row++

  create_window:(x, y) ->
    @context.fillRect x, y, 8, 16


class Sun
  constructor:(context) ->
    @mouth = true
    @context = context
    @color = '#FFFF00'
    @width = 50
    @y = 100

  position: ->
    1024/2

  draw:() ->
    @draw_circle()
    @rays()
    @eyes()
    @smile()

  draw_circle:() ->
    @context.fillStyle = @color
    @context.beginPath()
    @context.arc @position(), @y, @width, 0, Math.PI*2, true
    @context.closePath()
    @context.fill()

  eyes:() ->
    @context.fillStyle = '#000000'
    @context.beginPath()
    @context.arc @position()-10, @y-10, 5, 0, Math.PI*2,  true
    @context.arc @position()+10, @y-10, 5, 0, Math.PI*2,  true
    @context.fill()


  smile:() ->
    @context.strokeStyle = '#000000'
    @context.beginPath()
    @context.arc @position(), @y+20, 15, 0, Math.PI,  false
    @context.stroke()

  rays:() ->
    @context.strokeStyle = @color
    @context.beginPath()
    @draw_ray(360*z/36) for z in [0...50]
    @context.stroke()

  draw_ray:(a) ->
    @context.moveTo @position(), @y
    coords = @coordinates(@position(), @y, 75, a)
    @context.lineTo coords.x, coords.y

  coordinates:(x, y, d, a) ->
    x: x + d * Math.cos(a),
    y: y + d * Math.sin(a)


class Painter
  constructor: ->
    @canvas = document.getElementById "gorillas"
    @context = @canvas.getContext "2d"
    @color = '#00FFFF'

  draw_building:(x, y) ->
    building = new Building(@context, @color)
    building.draw(x, y)

  draw_the_sun: ->
    sun = new Sun(@context)
    sun.draw()

  set_color:(color) ->
    @color = color

window.onload = ->
  painter = new Painter
  painter.draw_the_sun()
  painter.draw_building(40, 145)
  painter.draw_building(141, 105)

  painter.set_color '#800000'
  painter.draw_the_sun
  painter.draw_building(242, 165)
  painter.draw_building(343, 155)
  painter.draw_building(444, 95)

  painter.set_color '#C0C0C0'
  painter.draw_building(545, 15)

  painter.set_color '#800000'
  painter.draw_building(646, 215)

  painter.set_color '#C0C0C0'
  painter.draw_building(747, 55)
  painter.set_color '#800000'
  painter.draw_building(848, 15)
  painter.draw_building(949, 0)
