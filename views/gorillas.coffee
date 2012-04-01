class Building
  constructor:(context, color) ->
    @context = context
    @width = 100
    @base_height = 135
    @color = color

  draw:(x,y) ->
    @context.fillStyle = @color
    @height = @base_height + y
    @context.fillRect x, 640-@height, @width, @height
    @build_windows(x, y)

  build_windows:(x, y) ->
    times = Math.round (@height)/31
    windows = [ 10, 25, 40, 55, 70, 85 ]
    current_distance = 30
    total_height = 30
    light = '#FFFF00'
    dark = '#808080'
    row = 1
    loop
      break if times < row
      @context.fillStyle = light
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
    @width = 40
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
    @context.arc @position(), @y+20, @width/4, 0, Math.PI,  false
    @context.stroke()

  rays:() ->
    @context.strokeStyle = @color
    @context.beginPath()
    @context.lineWidth = 1
    @draw_ray(360*z/36) for z in [0...50]
    @context.stroke()

  draw_ray:(a) ->
    @context.moveTo @position(), @y
    coords = @coordinates(@position(), @y, 65, a)
    @context.lineTo coords.x, coords.y

  coordinates:(x, y, d, a) ->
    x: x + d * Math.cos(a),
    y: y + d * Math.sin(a)


class Painter
  constructor: ->
    @canvas = document.getElementById "gorillas"
    @context = @canvas.getContext "2d"
    @color = '#00FFFF'

  draw_buildings:()->
    @draw_building(0, 145)
    @draw_building(101, 105)

    @set_color '#800000'
    @draw_building(202, 165)
    @draw_building(303, 155)
    @draw_building(404, 95)

    @set_color '#C0C0C0'
    @draw_building(505, 15)

    @set_color '#800000'
    @draw_building(606, 215)

    @set_color '#C0C0C0'
    @draw_building(707, 55)
    @set_color '#800000'
    @draw_building(808, 15)
    @draw_building(909, 0)


  draw_building:(x, y) ->
    building = new Building(@context, @color)
    building.draw(x, y)

  draw_the_sun: ->
    sun = new Sun(@context)
    sun.draw()

  set_color:(color) ->
    @color = color

  draw_gorillas: ->
    image = new Image()
    image.src = 'images/gorilla.png'
    @context.drawImage(image, 130, 640-280, 40, 40)
    @context.drawImage(image, 835, 640-190, 40, 40)

  draw_banana:(gorilla_x, gorilla_y) ->
    banana = new Banana(@context, gorilla_x+30, gorilla_y-30)
    banana.animate()

class Banana
  constructor:(context, initial_x, initial_y) ->
    @context = context
    @initx = initial_x
    @inity = initial_y
    @x = 0
    @y = 0
    @g = -9.80665

    F = 40
    angle = 70

    @dx = F/Math.cos(angle)
    @dy = F/Math.sin(angle)

  animate: ->
    @draw_frame()

  draw: ->
    @context.drawImage @image(), @initx+@x, @inity-@y

  draw_frame: ->
    @draw()
    @calculate_projection()

    setTimeout (=> @draw_frame()), 100

  calculate_projection:() ->
    @x += @dx
    @dy += @g
    @y += @dy

  image:() ->
    image = new Image()
    image.src = 'images/banana.png'
    return image


window.onload = ->
  painter = new Painter
  painter.draw_the_sun()
  painter.draw_buildings()

  painter.draw_gorillas()

  painter.draw_banana(130, 640-280)
