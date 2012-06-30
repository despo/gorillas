class Shape
  constructor:(@context) ->

  set_color:(color) ->
    @color = color

  draw_circle:(x, y, width) ->
    @context.fillStyle = @color
    @context.beginPath()
    @context.arc x, y, width, 0, Math.PI*2, true
    @context.closePath()
    @context.fill()

  draw_ellipse:(x, y, w, h) ->
    kappa = .5522848;
    ox = (w / 2) * kappa
    oy = (h / 2) * kappa
    xe = x + w
    ye = y + h
    xm = x + w / 2
    ym = y + h / 2

    @context.beginPath();
    @context.moveTo(x, ym);
    @context.bezierCurveTo(x, ym - oy, xm - ox, y, xm, y);
    @context.bezierCurveTo(xm + ox, y, xe, ym - oy, xe, ym);
    @context.bezierCurveTo(xe, ym + oy, xm + ox, ye, xm, ye);
    @context.bezierCurveTo(xm - ox, ye, x, ym + oy, x, ym);
    @context.closePath();
    @context.fill()

class Building
  constructor:(@context, @canvas_height) ->
    @width = 70 + Math.floor(Math.random()*40)
    @base_height = 100
    @randomize_color()
    @windows = []
    @colissions = []

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

  redraw_colissions:() ->
    if @colissions.length > 0
      @draw_colission(colission[0], colission[1]) for colission in @colissions

  build_windows:(x, y) ->
    if @windows.length > 0
      for window in @windows
        @create_window window[0], window[1], window[2]
      return

    rows = Math.round (@height)/26
    windows_per_floor = Math.floor(@width/15)
    current_distance = 25
    total_height = 30
    for row in [0...rows]
      for position in [1...windows_per_floor]
        color = @randomize_window_color()
        @create_window x+(position*15), 620+total_height-@height, color
        @windows.push [x+(position*15), 620+total_height-@height, color]

      total_height += current_distance

  create_window:(x, y, color) ->
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

  check_colission:(x, y) ->
    if @position_at_y()-10 <= y && (x > @x-10 && x < @x+@width-10)
      @colissions.push [x, y]
      @draw_colission(x, y)
      return true
    false

  draw_colission:(x, y) ->
    color = '#0000a0'
    @context.fillStyle = color
    shape = new Shape(@context)
    shape.draw_ellipse(x, y, 35, 25)

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
    @draw_body()
    @rays()
    @eyes()
    @smile()

  draw_body:() ->
    shape = new Shape @context
    shape.set_color @color
    shape.draw_circle @position(), @y, @width

  eyes:() ->
    shape = new Shape(@context)
    shape.set_color '#000000'
    shape.draw_circle @position()-10, @y-10, 5
    shape.draw_circle @position()+10, @y-10, 5

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
    @winner = []
    @color = '#00FFFF'
    @padding = 1
    @buildings = []
    @f = 10

  draw_scene: ->
    @clear()
    @draw_the_sun()
    unless @empty
      @redraw_buildings()
      @redraw_colissions()
      @redraw_gorillas()
    else
      @empty = false
      @draw_buildings()
      setTimeout (=>
        @draw_gorillas()
      ),
      500

  redraw_buildings: ->
    for pos in [0...@buildings.length]
      @buildings[pos].redraw()

  redraw_colissions: ->
    for pos in [0...@buildings.length]
      @buildings[pos].redraw_colissions()

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

  clear: ->
    @canvas.width = @canvas.width

  clear_timeouts: ->
    clearTimeout(@timeout)

  draw_gorillas: ->
    building_1_position = Math.floor(Math.random()*@buildings.length/2)
    building = @buildings[building_1_position]
    @player_1 = new Gorilla(@context, 1)
    @player_1.draw(building.middle_position(), building.position_at_y())

    building_2_position = Math.floor(Math.random()*(@buildings.length - 2 - building_1_position)) + building_1_position+1
    building = @buildings[building_2_position]
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
      @start_time = new Date()

      @animate_banana(player, @start_time)
      ),
      @f

  update_score: ->
    player_1 = @winner.filter((x) => x == 1).length
    player_2 = @winner.filter((x) => x == 2).length

    $('#score label').text(player_1 + '>Score<' + player_2)

  animate_banana:(player) ->
    @timeout = setTimeout (=>
      @draw_scene()
      if @banana_hit_gorilla(player) == true
        return
      if @banana_has_collided(player) == true
        @next_player_turn(player)
        return
      if @within_boundaries(player.banana.x(), player.banana.y()) == false
        @next_player_turn(player)
        return

      now = new Date()
      time = now - @start_time

      player.throw_banana(time/1000, time)
      @animate_banana(player)
      ),
      @f

  banana_has_collided:(player) ->
    x = player.banana.x()
    y = player.banana.y()
    for building in @buildings
      return true if building.check_colission x, y
    false

  banana_hit_gorilla:(player) ->
    x = player.banana.x()
    y = player.banana.y()
    if @player_2.check_colission(x, y) || @player_1.check_colission(x, y)
      dead_player = if @player_2.dead == true then @player_2 else @player_1
      winner = if @player_2.dead == false then @player_2 else @player_1
      @winner.push winner.player_number
      @timeout = setTimeout (=>
        @animate_colission(dead_player)
      ),
      0
      @update_score()
      @timeout = setTimeout (=>
        @start_time = new Date()
        winner.animate = true
        @draw_scene()
        player.animate_win()
        @animate_win(winner, @start_time)
        ),
        @f
      return true

  animate_colission:(player) ->
    @timeout = setTimeout (=>
      @start_time = new Date()
      player.animate_colission()
      @animate_colission(player) unless player.explosion_width > player.width
      ),
      0


  animate_win:(player, @start_time) ->
    @timeout = setTimeout (=>
      unless player.animate == true and player.animations < 12
        @empty = true
        @buildings = []
        @draw_scene()
        @next_player_turn(player)
        return

      now = new Date()
      time = now - @start_time
      @draw_scene()
      player.animate_win()
      @animate_win(player, @start_time)
      ),
      800

  next_player_turn:(player) ->
    next_player = if player.player_number == 2 then 1 else 2
    window.show_player_field('player_'+next_player, 'angle')

  within_boundaries:(x, y) ->
    return false if x < 0 || x > @width || y > @height

  draw_ray:(x, y, a) ->
    @context.moveTo x, y
    coords = @coordinates(x, y, 20, a)
    @context.lineTo coords.x, coords.y

  coordinates:(x, y, d, a) ->
    x: x + d * Math.cos(a),
    y: y + d * Math.sin(a)


class Gorilla
  constructor:(@context, @player_number) ->
    @wins = 0
    @width = 40
    @dead = false
    @height = 40
    @animate = false
    @animations = 0
    @right_hand = false
    @explosion_width = @width
    @explosion_height = @height

  image: ->
    @current_image ||= @still_state()
    @current_image

  reset_image: ->
    @current_image = @still_state()

  use_right_hand_image: ->
    @current_image = @right_hand_image()

  use_left_hand_image: ->
    @current_image = @left_hand_image()

  draw:(x, y) ->
    if @dead == true
      @draw_as_dead()
      return
    @x ||= x-@width/2
    @y ||= y-@height
    @context.drawImage(@image(), @x, @y, @width, @height)
    @reset_image()

  redraw:() ->
    @draw(@x, @y)

  grab_banana:(force, angle) ->
    @banana = new Banana(@context, @x, @y-@height, force, angle)

  draw_as_dead: ->
    @context.fillStyle = '#0000a0'
    shape = new Shape(@context)
    shape.draw_ellipse(@x-@width, @y, 2.5*@explosion_width, @explosion_height)

  animate_colission:() ->
    @context.fillStyle = '#F50B0B'
    @explosion_width += 20
    @explosion_height += 20
    width = @explosion_width
    height = @explosion_height

    shape = new Shape(@context)
    shape.draw_ellipse(@x-@width, @y, 2.5*width, height)

  throw_banana:(time, just_thrown) ->
    if @player_number == 2 and just_thrown == true
      @use_left_hand_image()
    else if just_thrown == true
      @use_right_hand_image()
    @context.drawImage(@image(), @x, @y, @width, @height)
    @banana.draw_frame(time)

  check_colission:(x, y) ->
    if (@y <= y ) && (x > @x-@width/2 &&  x < @x+@width/2)
      @dead = true
      return true
    false

  still_state: ->
    image = new Image()
    image.src = 'images/gorilla.png'
    image

  right_hand_image: ->
    image = new Image()
    image.src = 'images/gorilla-right-hand-up.png'
    image

  left_hand_image: ->
    image = new Image()
    image.src = 'images/gorilla-left-hand-up.png'
    image

  animate_win: ->
    @right_hand = !@right_hand
    @animations++
    if @right_hand == true
      return @use_left_hand_image()
    return @use_right_hand_image()


class Banana
  constructor:(@context, @initx, @inity, @force, @angle) ->
    @projection_x = 0
    @projection_y = 0
    @scale = 0.1
    @g = 9.8
    @calculate_initial_position()
    @start_time = 0
    @wind = 15

  x: ->
    @initx + @projection_x

  y: ->
    @inity - @projection_y

  draw: ->
    @context.drawImage @image(), @x(), @y()

  draw_frame:(time) ->
    @start_time = time
    @draw()
    @calculate_projection()

  calculate_initial_position: ->
    radian = @angle*Math.PI/180
    @dx = @force*Math.cos(radian)
    @dy = @force*Math.sin(radian)-@g*@start_time

  calculate_projection:() ->
    @calculate_initial_position()
    @projection_x += @dx*@scale
    @projection_y += @dy*@scale

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

window.is_field_visible = (player, field) ->
  $('#'+player+'_'+field).is(":visible")


jQuery = $
$(document).ready ->
  painter = new Painter
  painter.draw_scene()

  $('#player_1_angle').bind "keydown", (event) ->
    if event.keyCode == 13
      painter.clear_timeouts()
      window.show_player_field 'player_1', 'velocity'

  $('#player_1_velocity').bind "keydown", (event) ->
    if event.keyCode == 13 && window.is_field_visible  'player_1', 'angle'

      console.log "----------"
      window.hide_player_field 'player_1', 'angle'
      window.hide_player_field 'player_1', 'velocity'


      parameters = window.read_angle_and_velocity('player_1')
      parameters.velocity = 0 unless parameters.velocity > 0
      parameters.angle = 0 unless parameters.angle > 0
      window.clear_fields 'player_1'
      painter.throw_banana(parseInt(parameters.velocity), parseInt(parameters.angle), 1)

  $('#player_2_angle').bind "keydown", (event) ->
    if event.keyCode == 13
      painter.clear_timeouts()
      window.show_player_field 'player_2', 'velocity'

  $('#player_2_velocity').bind "keydown", (event) ->
    if event.keyCode == 13 and window.is_field_visible 'player_2', 'angle'
      window.hide_player_field 'player_2', 'angle'
      window.hide_player_field 'player_2', 'velocity'

      parameters = window.read_angle_and_velocity('player_2')
      window.clear_fields 'player_2'
      painter.throw_banana(parseInt(parameters.velocity), parseInt(parameters.angle), 2)

  $('#player_1_angle').show()
  $('#player_1_angle').prev().show()
  $('#player_1_angle').focus()
