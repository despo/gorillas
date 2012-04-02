class Building
  constructor:(@context, @canvas_height) ->
    @width = 70 + Math.floor(Math.random()*40)
    @base_height = 100
    @randomize_color()

  position_at_x:() ->
    return @x

  position_at_y:() ->
    return  @canvas_height-@height

  end_position:() ->
    return @position_at_x()+@width

  middle_position: ->
    return @position_at_x() + (@end_position() - @position_at_x())/2

  draw:(@x, @y) ->
    @context.fillStyle = @color
    @height = @base_height + y
    @context.fillRect @position_at_x(), @position_at_y(), @width, @height
    @build_windows(@position_at_x(), @position_at_y())

  redraw: ->
    @draw(@x, @y)

  build_windows:(x, y) ->
    rows = Math.round (@height)/31
    windows_per_floor = Math.floor(@width/15)
    current_distance = 30
    total_height = 30
    for row in [0...rows]
      @create_window x+(position*15), 620+total_height-@height for position in [1...windows_per_floor]
      total_height += current_distance

  create_window:(x, y) ->
    color = @randomize_window_color()
    @context.fillStyle = color
    @context.fillRect x, y, 8, 16

  randomize_color:() ->
    colors = [ '#C0C0C0', '#800000', '#00FFFF' ]
    random = Math.floor(Math.random()*colors.length)
    @color ||= colors[random]

  randomize_window_color:() ->
    colors = [ '#808080', '#FFFF00' ]
    random = Math.floor(Math.random()*5)
    color = if random > 0 then colors[1] else colors[random]
    color

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
    @empty = true
    @canvas = document.getElementById "gorillas"
    @width = @canvas.width
    @height = @canvas.height
    @context = @canvas.getContext "2d"
    @color = '#00FFFF'
    @padding = 1
    @buildings = []

  draw_scene: ->
    unless @empty
      @clear()
      @draw_the_sun()
      @redraw_buildings()
      @redraw_gorillas()
    else
      @empty = false
      @draw_the_sun()
      @draw_buildings()
      @draw_gorillas()

  redraw_buildings:()->
    for pos in [0...@buildings.length]
      @buildings[pos].redraw()

  draw_buildings:()->
    position = 0
    while position < @width
      building = @draw_building(position)
      position = building.end_position() + @padding

  draw_building:(x) ->
    building = new Building(@context, @height)

    y = Math.floor(Math.random()*300)
    building.draw(x, y)
    @buildings.push building
    return building

  draw_the_sun: ->
    sun = new Sun(@context)
    sun.draw()

  set_color:(@color) ->

  clear:() ->
    @canvas.width = @canvas.width

  clear_timeouts: ->
    clearTimeout(@timeout)

  draw_gorillas: ->
    building = @buildings[Math.floor(Math.random()*3)]
    @player_1 = new Gorilla(@context, 1)
    @player_1.draw(building.middle_position(), building.position_at_y())

    building = @buildings[Math.floor(Math.random()*6)+3]
    @player_2 = new Gorilla(@context, 2)
    @player_2.draw(building.middle_position(), building.position_at_y())

  redraw_gorillas: ->
    @player_1.redraw()
    @player_2.redraw()

  throw_banana:(force, angle, player) ->
    if player == 2
      angle = -angle
      force = -force
    player = this['player_' + player]
    player.grab_banana(force, angle)
    @timeout = setTimeout (=>
      @animate_banana(player)
      ),
      150

  animate_banana:(player) ->
    @timeout = setTimeout (=>
      @draw_scene()
      if @within_boundaries(player.banana.x(), player.banana.y()) == false
        @next_player_turn(player)
        return

      player.throw_banana()

      @animate_banana(player)
      ),
      150

  next_player_turn:(player) ->
    next_player = if player.player_number == 2 then 1 else 2
    window.show_player_field('player_'+next_player, 'angle')

  within_boundaries:(x, y) ->
    return false if x < 0 || x > @width || y > @height || y < 0

class Gorilla
  constructor:(@context, @player_number) ->
    @width = 25
    @height = 25

  image: ->
    image = new Image()
    image.src = 'images/gorilla.png'
    image

  draw:(x, y) ->
    @x ||= x-@width/2
    @y ||= y-@height
    @context.drawImage(@image(), @x, @y, @width, @height)

  redraw:() ->
    @draw(@x, @y)

  grab_banana:(force, angle) ->
    @banana = new Banana(@context, @x+@width, @y-@height, force, angle)

  throw_banana: ->
    @banana.draw_frame()

class Banana
  constructor:(@context, @initx, @inity, @force, @angle) ->
    @projection_x = 0
    @projection_y = 0
    @g = 9.8
    @calculate_initial_position()

  x: ->
    @initx + @projection_x

  y: ->
    @inity - @projection_y

  draw: ->
    @context.drawImage @image(), @x(), @y()

  draw_frame: ->
    @draw()
    @calculate_projection()

  calculate_initial_position: ->
    radian = @angle*Math.PI/180
    @dx = @force/Math.cos(radian)
    @dy = @force/Math.sin(radian)

  calculate_projection:() ->
    @projection_x += @dx
    @dy -= @g
    @projection_y += @dy

  image:() ->
    image = new Image()
    image.src = 'images/banana.png'
    return image

window.hide_player_field = (player, field) ->
  $('#'+player+'_'+field).hide()
  $('#'+player+'_'+field).prev().hide()

window.show_player_field = (player, field) ->
  $('#'+player+'_'+field).show()
  $('#'+player+'_'+field).prev().show()
  $('#'+player+'_'+field).focus()

window.read_angle_and_velocity = (player) ->
  angle: $('#'+player+'_angle').val(),
  velocity: $('#'+player+'_velocity').val()

window.clear_fields = (player) ->
  $('#'+player+'_angle').val('')
  $('#'+player+'_velocity').val('')


jQuery = $
$(document).ready ->
  painter = new Painter
  painter.draw_scene()

  $('#player_1_angle').bind "keydown", (event) ->
    if event.keyCode == 13
      painter.clear_timeouts()
      window.hide_player_field 'player_1', 'angle'
      window.show_player_field 'player_1', 'velocity'

  $('#player_1_velocity').bind "keydown", (event) ->
    if event.keyCode == 13
      window.hide_player_field 'player_1', 'velocity'

      parameters = window.read_angle_and_velocity('player_1')
      window.clear_fields 'player_1'
      painter.throw_banana(parseInt(parameters.angle), parseInt(parameters.velocity), 1)

  $('#player_2_angle').bind "keydown", (event) ->
    if event.keyCode == 13
      painter.clear_timeouts()
      window.hide_player_field 'player_2', 'angle'
      window.show_player_field 'player_2', 'velocity'

  $('#player_2_velocity').bind "keydown", (event) ->
    if event.keyCode == 13
      window.hide_player_field 'player_2', 'velocity'

      parameters = window.read_angle_and_velocity('player_2')
      window.clear_fields 'player_2'
      painter.throw_banana(parseInt(parameters.angle), parseInt(parameters.velocity), 2)

  $('#player_1_angle').show()
  $('#player_1_angle').prev().show()
  $('#player_1_angle').focus()
