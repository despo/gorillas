(function() {
  var Banana, Building, Gorilla, Painter, Shape, Sun, jQuery;

  Shape = class Shape {
    constructor(context1) {
      this.context = context1;
    }

    set_color(color) {
      return this.color = color;
    }

    draw_circle(x, y, width) {
      this.context.fillStyle = this.color;
      this.context.beginPath();
      this.context.arc(x, y, width, 0, Math.PI * 2, true);
      this.context.closePath();
      return this.context.fill();
    }

    draw_ellipse(x, y, w, h) {
      var kappa, ox, oy, xe, xm, ye, ym;
      kappa = .5522848;
      ox = (w / 2) * kappa;
      oy = (h / 2) * kappa;
      xe = x + w;
      ye = y + h;
      xm = x + w / 2;
      ym = y + h / 2;
      this.context.beginPath();
      this.context.moveTo(x, ym);
      this.context.bezierCurveTo(x, ym - oy, xm - ox, y, xm, y);
      this.context.bezierCurveTo(xm + ox, y, xe, ym - oy, xe, ym);
      this.context.bezierCurveTo(xe, ym + oy, xm + ox, ye, xm, ye);
      this.context.bezierCurveTo(xm - ox, ye, x, ym + oy, x, ym);
      this.context.closePath();
      return this.context.fill();
    }

  };

  Building = class Building {
    constructor(context1, canvas_height) {
      this.context = context1;
      this.canvas_height = canvas_height;
      this.width = 70 + Math.floor(Math.random() * 40);
      this.base_height = 100;
      this.randomize_color();
      this.windows = [];
      this.collisions = [];
    }

    position_at_x() {
      return this.x;
    }

    position_at_y() {
      return this.canvas_height - this.height;
    }

    end_position() {
      return this.position_at_x() + this.width;
    }

    middle_position() {
      return this.position_at_x() + (this.end_position() - this.position_at_x()) / 2;
    }

    draw(x1, y1) {
      this.x = x1;
      this.y = y1;
      this.context.fillStyle = this.color;
      this.height = this.base_height + this.y;
      this.context.fillRect(this.position_at_x(), this.position_at_y(), this.width, this.height);
      return this.build_windows(this.position_at_x(), this.position_at_y());
    }

    redraw() {
      return this.draw(this.x, this.y);
    }

    redraw_collisions() {
      var collision, i, len, ref, results;
      if (this.collisions.length > 0) {
        ref = this.collisions;
        results = [];
        for (i = 0, len = ref.length; i < len; i++) {
          collision = ref[i];
          results.push(this.draw_collision(collision[0], collision[1]));
        }
        return results;
      }
    }

    build_windows(x, y) {
      var color, current_distance, i, j, k, len, position, ref, ref1, ref2, results, row, rows, total_height, window, windows_per_floor;
      if (this.windows.length > 0) {
        ref = this.windows;
        for (i = 0, len = ref.length; i < len; i++) {
          window = ref[i];
          this.create_window(window[0], window[1], window[2]);
        }
        return;
      }
      rows = Math.round(this.height / 26);
      windows_per_floor = Math.floor(this.width / 15);
      current_distance = 25;
      total_height = 30;
      results = [];
      for (row = j = 0, ref1 = rows; (0 <= ref1 ? j < ref1 : j > ref1); row = 0 <= ref1 ? ++j : --j) {
        for (position = k = 1, ref2 = windows_per_floor; (1 <= ref2 ? k < ref2 : k > ref2); position = 1 <= ref2 ? ++k : --k) {
          color = this.randomize_window_color();
          this.create_window(x + (position * 15), 620 + total_height - this.height, color);
          this.windows.push([x + (position * 15), 620 + total_height - this.height, color]);
        }
        results.push(total_height += current_distance);
      }
      return results;
    }

    create_window(x, y, color) {
      this.context.fillStyle = color;
      return this.context.fillRect(x, y, 8, 16);
    }

    randomize_color() {
      var colors, random;
      colors = ['#C0C0C0', '#800000', '#00FFFF'];
      random = Math.floor(Math.random() * colors.length);
      return this.color || (this.color = colors[random]);
    }

    randomize_window_color() {
      var color, colors, random;
      colors = ['#808080', '#FFFF00'];
      random = Math.floor(Math.random() * 5);
      color = random > 0 ? colors[1] : colors[random];
      return color;
    }

    check_collision(x, y) {
      if (this.position_at_y() - 10 <= y && (x > this.x - 10 && x < this.x + this.width - 10)) {
        this.collisions.push([x, y]);
        this.draw_collision(x, y);
        return true;
      }
      return false;
    }

    draw_collision(x, y) {
      var color, shape;
      color = '#0000a0';
      this.context.fillStyle = color;
      shape = new Shape(this.context);
      return shape.draw_ellipse(x, y, 35, 25);
    }

  };

  Sun = class Sun {
    constructor(context, smiling = false) {
      this.mouth = true;
      this.context = context;
      this.color = '#FFFF00';
      this.width = 40;
      this.y = 100;
      this.smiling = smiling;
    }

    position() {
      return 1024 / 2;
    }

    draw() {
      this.draw_body();
      this.rays();
      this.eyes();
      return this.smile();
    }

    draw_body() {
      var shape;
      shape = new Shape(this.context);
      shape.set_color(this.color);
      return shape.draw_circle(this.position(), this.y, this.width);
    }

    eyes() {
      var shape;
      shape = new Shape(this.context);
      shape.set_color('#000000');
      shape.draw_circle(this.position() - 10, this.y - 10, 5);
      return shape.draw_circle(this.position() + 10, this.y - 10, 5);
    }

    smile() {
      this.context.strokeStyle = '#000000';
      this.context.beginPath();
      if (this.smiling) {
        this.context.arc(this.position(), this.y + 20, this.width / 4, 0, Math.PI, false);
      } else {
        this.context.arc(this.position(), this.y + 20, this.width / 4, Math.PI / 8, Math.PI * 7 / 8, false);
      }
      return this.context.stroke();
    }

    rays() {
      var i, z;
      this.context.strokeStyle = this.color;
      this.context.beginPath();
      this.context.lineWidth = 1;
      for (z = i = 0; i < 50; z = ++i) {
        this.draw_ray(360 * z / 36);
      }
      return this.context.stroke();
    }

    draw_ray(a) {
      var coords;
      this.context.moveTo(this.position(), this.y);
      coords = this.coordinates(this.position(), this.y, 65, a);
      return this.context.lineTo(coords.x, coords.y);
    }

    coordinates(x, y, d, a) {
      return {
        x: x + d * Math.cos(a),
        y: y + d * Math.sin(a)
      };
    }

    check_collision(x, y) {
      var delta_x, delta_y;
      delta_x = x - this.position();
      delta_x = delta_x * delta_x;
      delta_y = y - this.y;
      delta_y = delta_y * delta_y;
      return Math.sqrt(delta_x + delta_y) < this.width;
    }

  };

  Painter = class Painter {
    constructor() {
      this.empty = true;
      this.canvas = document.getElementById("gorillas");
      this.width = this.canvas.width;
      this.height = this.canvas.height;
      this.context = this.canvas.getContext("2d");
      this.winner = [];
      this.color = '#00FFFF';
      this.padding = 1;
      this.buildings = [];
      this.f = 10;
      this.similing_sun = false;
    }

    draw_scene() {
      this.clear();
      this.draw_the_sun();
      if (!this.empty) {
        this.redraw_buildings();
        this.redraw_collisions();
        return this.redraw_gorillas();
      } else {
        this.empty = false;
        this.draw_buildings();
        this.draw_gorillas();
        return setTimeout((() => {
          return this.draw_gorillas();
        }), 200);
      }
    }

    redraw_buildings() {
      var i, pos, ref, results;
      results = [];
      for (pos = i = 0, ref = this.buildings.length; (0 <= ref ? i < ref : i > ref); pos = 0 <= ref ? ++i : --i) {
        results.push(this.buildings[pos].redraw());
      }
      return results;
    }

    redraw_collisions() {
      var i, pos, ref, results;
      results = [];
      for (pos = i = 0, ref = this.buildings.length; (0 <= ref ? i < ref : i > ref); pos = 0 <= ref ? ++i : --i) {
        results.push(this.buildings[pos].redraw_collisions());
      }
      return results;
    }

    draw_buildings() {
      var building, position, results;
      position = 0;
      results = [];
      while (position < this.width) {
        building = this.draw_building(position);
        results.push(position = building.end_position() + this.padding);
      }
      return results;
    }

    draw_building(x) {
      var building, y;
      building = new Building(this.context, this.height);
      y = Math.floor(Math.random() * 300);
      building.draw(x, y);
      this.buildings.push(building);
      return building;
    }

    draw_the_sun() {
      var sun;
      sun = new Sun(this.context, this.smiling_sun);
      return sun.draw();
    }

    set_color(color1) {
      this.color = color1;
    }

    clear() {
      return this.canvas.width = this.canvas.width;
    }

    clear_timeouts() {
      return clearTimeout(this.timeout);
    }

    draw_gorillas() {
      var building, building_1_position, building_2_position;
      building_1_position = Math.floor(Math.random() * this.buildings.length / 2);
      building = this.buildings[building_1_position];
      this.player_1 = new Gorilla(this.context, 1);
      this.player_1.draw(building.middle_position(), building.position_at_y());
      building_2_position = Math.floor(Math.random() * (this.buildings.length - 2 - building_1_position)) + building_1_position + 1;
      building = this.buildings[building_2_position];
      this.player_2 = new Gorilla(this.context, 2);
      return this.player_2.draw(building.middle_position(), building.position_at_y());
    }

    redraw_gorillas() {
      this.player_1.redraw();
      return this.player_2.redraw();
    }

    throw_banana(force, angle, player) {
      if (player === 2) {
        angle = -angle;
        force = -force;
      }
      player = this['player_' + player];
      player.grab_banana(force, angle);
      return this.timeout = setTimeout((() => {
        this.start_time = new Date();
        return this.animate_banana(player, this.start_time);
      }), this.f);
    }

    update_score() {
      var player_1, player_2;
      player_1 = this.winner.filter((x) => {
        return x === 1;
      }).length;
      player_2 = this.winner.filter((x) => {
        return x === 2;
      }).length;
      return $('#score label').text(player_1 + '>Score<' + player_2);
    }

    animate_banana(player) {
      return this.timeout = setTimeout((() => {
        var now, time;
        this.draw_scene();
        if (this.banana_hit_sun(player) === true) {
          this.smiling_sun = true;
        }
        if (this.banana_hit_gorilla(player) === true) {
          return;
        }
        if (this.banana_has_collided(player) === true) {
          this.next_player_turn(player);
          return;
        }
        if (this.within_boundaries(player.banana.x(), player.banana.y()) === false) {
          this.next_player_turn(player);
          return;
        }
        now = new Date();
        time = now - this.start_time;
        player.throw_banana(time / 1000, time);
        return this.animate_banana(player);
      }), this.f);
    }

    banana_hit_sun(player) {
      var x, y;
      x = player.banana.x();
      y = player.banana.y();
      return new Sun(this.context).check_collision(x, y);
    }

    banana_has_collided(player) {
      var building, i, len, ref, x, y;
      x = player.banana.x();
      y = player.banana.y();
      ref = this.buildings;
      for (i = 0, len = ref.length; i < len; i++) {
        building = ref[i];
        if (building.check_collision(x, y)) {
          return true;
        }
      }
      return false;
    }

    banana_hit_gorilla(player) {
      var dead_player, winner, x, y;
      x = player.banana.x();
      y = player.banana.y();
      if (this.player_2.check_collision(x, y) || this.player_1.check_collision(x, y)) {
        dead_player = this.player_2.dead === true ? this.player_2 : this.player_1;
        winner = this.player_2.dead === false ? this.player_2 : this.player_1;
        this.winner.push(winner.player_number);
        this.timeout = setTimeout((() => {
          return this.animate_collision(dead_player);
        }), 0);
        this.update_score();
        this.timeout = setTimeout((() => {
          this.start_time = new Date();
          winner.animate = true;
          this.draw_scene();
          player.animate_win();
          return this.animate_win(winner, this.start_time);
        }), this.f);
        return true;
      }
    }

    animate_collision(player) {
      return this.timeout = setTimeout((() => {
        this.start_time = new Date();
        player.animate_collision();
        if (!(player.explosion_width > player.width)) {
          return this.animate_collision(player);
        }
      }), 0);
    }

    animate_win(player, start_time) {
      this.start_time = start_time;
      return this.timeout = setTimeout((() => {
        var now, time;
        if (!(player.animate === true && player.animations < 12)) {
          this.empty = true;
          this.buildings = [];
          this.draw_scene();
          this.next_player_turn(player);
          return;
        }
        now = new Date();
        time = now - this.start_time;
        this.draw_scene();
        player.animate_win();
        return this.animate_win(player, this.start_time);
      }), 800);
    }

    next_player_turn(player) {
      var next_player;
      next_player = player.player_number === 2 ? 1 : 2;
      return window.show_player_field('player_' + next_player, 'angle');
    }

    within_boundaries(x, y) {
      if (x < 0 || x > this.width || y > this.height) {
        return false;
      }
    }

    draw_ray(x, y, a) {
      var coords;
      this.context.moveTo(x, y);
      coords = this.coordinates(x, y, 20, a);
      return this.context.lineTo(coords.x, coords.y);
    }

    coordinates(x, y, d, a) {
      return {
        x: x + d * Math.cos(a),
        y: y + d * Math.sin(a)
      };
    }

  };

  Gorilla = class Gorilla {
    constructor(context1, player_number) {
      this.context = context1;
      this.player_number = player_number;
      this.wins = 0;
      this.width = 40;
      this.dead = false;
      this.height = 40;
      this.animate = false;
      this.animations = 0;
      this.right_hand = false;
      this.explosion_width = this.width;
      this.explosion_height = this.height;
    }

    image() {
      this.current_image || (this.current_image = this.still_state());
      return this.current_image;
    }

    reset_image() {
      return this.current_image = this.still_state();
    }

    use_right_hand_image() {
      return this.current_image = this.right_hand_image();
    }

    use_left_hand_image() {
      return this.current_image = this.left_hand_image();
    }

    draw(x, y) {
      if (this.dead === true) {
        this.draw_as_dead();
        return;
      }
      this.x || (this.x = x - this.width / 2);
      this.y || (this.y = y - this.height);
      this.context.drawImage(this.image(), this.x, this.y, this.width, this.height);
      return this.reset_image();
    }

    redraw() {
      return this.draw(this.x, this.y);
    }

    grab_banana(force, angle) {
      return this.banana = new Banana(this.context, this.x, this.y - this.height, force, angle);
    }

    draw_as_dead() {
      var shape;
      this.context.fillStyle = '#0000a0';
      shape = new Shape(this.context);
      return shape.draw_ellipse(this.x - this.width, this.y, 2.5 * this.explosion_width, this.explosion_height);
    }

    animate_collision() {
      var height, shape, width;
      this.context.fillStyle = '#F50B0B';
      this.explosion_width += 20;
      this.explosion_height += 20;
      width = this.explosion_width;
      height = this.explosion_height;
      shape = new Shape(this.context);
      return shape.draw_ellipse(this.x - this.width, this.y, 2.5 * width, height);
    }

    throw_banana(time, just_thrown) {
      if (this.player_number === 2 && just_thrown === true) {
        this.use_left_hand_image();
      } else if (just_thrown === true) {
        this.use_right_hand_image();
      }
      this.context.drawImage(this.image(), this.x, this.y, this.width, this.height);
      return this.banana.draw_frame(time);
    }

    check_collision(x, y) {
      if ((this.y <= y) && (x > this.x - this.width / 2 && x < this.x + this.width / 2)) {
        this.dead = true;
        return true;
      }
      return false;
    }

    still_state() {
      var image;
      image = new Image();
      image.src = 'images/gorilla.png';
      return image;
    }

    right_hand_image() {
      var image;
      image = new Image();
      image.src = 'images/gorilla-right-hand-up.png';
      return image;
    }

    left_hand_image() {
      var image;
      image = new Image();
      image.src = 'images/gorilla-left-hand-up.png';
      return image;
    }

    animate_win() {
      this.right_hand = !this.right_hand;
      this.animations++;
      if (this.right_hand === true) {
        return this.use_left_hand_image();
      }
      return this.use_right_hand_image();
    }

  };

  Banana = class Banana {
    constructor(context1, initx, inity, force1, angle1) {
      this.context = context1;
      this.initx = initx;
      this.inity = inity;
      this.force = force1;
      this.angle = angle1;
      this.projection_x = 0;
      this.projection_y = 0;
      this.scale = 0.1;
      this.g = 9.8;
      this.calculate_initial_position();
      this.start_time = 0;
      this.wind = 15;
      this.rotation = 0;
      this.img = this.image();
      this.img_w_div_2 = this.img.width / 2.0;
      this.img_h_div_2 = this.img.height / 2.0;
    }

    x() {
      return this.initx + this.projection_x;
    }

    y() {
      return this.inity - this.projection_y;
    }

    draw() {
      var x, y;
      x = this.x();
      y = this.y();
      this.context.translate(x, y);
      this.context.translate(this.img_w_div_2, this.img_h_div_2);
      this.context.rotate(this.rotation);
      this.context.drawImage(this.img, -this.img_w_div_2, -this.img_h_div_2);
      this.context.rotate(-this.rotation);
      this.context.translate(-this.img_w_div_2, -this.img_h_div_2);
      return this.context.translate(x, y);
    }

    draw_frame(time) {
      this.start_time = time;
      this.rotation = time * 10;
      this.draw();
      return this.calculate_projection();
    }

    calculate_initial_position() {
      var radian;
      radian = this.angle * Math.PI / 180;
      this.dx = this.force * Math.cos(radian);
      return this.dy = this.force * Math.sin(radian) - this.g * this.start_time;
    }

    calculate_projection() {
      this.calculate_initial_position();
      this.projection_x += this.dx * this.scale;
      return this.projection_y += this.dy * this.scale;
    }

    image() {
      var image;
      image = new Image();
      image.src = 'images/banana.png';
      return image;
    }

  };

  window.hide_player_field = function(player, field) {
    $('#' + player + '_' + field).hide();
    return $('#' + player + '_' + field).prev().hide();
  };

  window.show_player_field = function(player, field) {
    $('#' + player + '_' + field).show();
    $('#' + player + '_' + field).prev().show();
    return $('#' + player + '_' + field).focus();
  };

  window.read_angle_and_velocity = function(player) {
    return {
      angle: $('#' + player + '_angle').val(),
      velocity: $('#' + player + '_velocity').val()
    };
  };

  window.clear_fields = function(player) {
    $('#' + player + '_angle').val('');
    return $('#' + player + '_velocity').val('');
  };

  window.is_field_visible = function(player, field) {
    return $('#' + player + '_' + field).is(":visible");
  };

  jQuery = $;

  $(document).ready(function() {
    var painter;
    painter = new Painter();
    painter.draw_scene();
    $('#player_1_angle').bind("keydown", function(event) {
      if (event.keyCode === 13) {
        painter.clear_timeouts();
        return window.show_player_field('player_1', 'velocity');
      }
    });
    $('#player_1_velocity').bind("keydown", function(event) {
      var parameters;
      if (event.keyCode === 13 && window.is_field_visible('player_1', 'angle')) {
        console.log("----------");
        window.hide_player_field('player_1', 'angle');
        window.hide_player_field('player_1', 'velocity');
        parameters = window.read_angle_and_velocity('player_1');
        if (!(parameters.velocity > 0)) {
          parameters.velocity = 0;
        }
        if (!(parameters.angle > 0)) {
          parameters.angle = 0;
        }
        window.clear_fields('player_1');
        return painter.throw_banana(parseInt(parameters.velocity), parseInt(parameters.angle), 1);
      }
    });
    $('#player_2_angle').bind("keydown", function(event) {
      if (event.keyCode === 13) {
        painter.clear_timeouts();
        return window.show_player_field('player_2', 'velocity');
      }
    });
    $('#player_2_velocity').bind("keydown", function(event) {
      var parameters;
      if (event.keyCode === 13 && window.is_field_visible('player_2', 'angle')) {
        window.hide_player_field('player_2', 'angle');
        window.hide_player_field('player_2', 'velocity');
        parameters = window.read_angle_and_velocity('player_2');
        window.clear_fields('player_2');
        return painter.throw_banana(parseInt(parameters.velocity), parseInt(parameters.angle), 2);
      }
    });
    $('#player_1_angle').show();
    $('#player_1_angle').prev().show();
    return $('#player_1_angle').focus();
  });

}).call(this);
