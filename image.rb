require "rubygems"
require "cairo"

# TTTの画像を保存するためのモジュール
module TTTImage
  GRID = 64
  SIZE = GRID * 3
  SYMBOL = 24

  def self.draw_circle(pos, context)
    x = pos % 3
    y = pos / 3
    x = (x + 0.5) * GRID
    y = (y + 0.5) * GRID
    context.set_source_rgb(0, 0, 0)
    context.circle(x, y, SYMBOL)
    context.stroke
  end

  def self.pos2grid(pos)
    x = pos % 3 + 0.5
    y = pos / 3 + 0.5
    x *= GRID
    y *= GRID
    [x, y]
  end

  def self.draw_x(pos, context)
    x, y = pos2grid(pos)
    context.set_source_rgb(0, 0, 0)
    x1 = x - SYMBOL
    x2 = x + SYMBOL
    y1 = y - SYMBOL
    y2 = y + SYMBOL
    context.move_to(x1, y1)
    context.line_to(x2, y2)
    context.move_to(x1, y2)
    context.line_to(x2, y1)
    context.stroke
  end

  def self.draw_grid(context)
    context.set_source_rgb(0, 0, 0)
    (1..2).each do |i|
      context.move_to(i * GRID, 0)
      context.line_to(i * GRID, SIZE)
      context.stroke
      context.move_to(0, i * GRID)
      context.line_to(SIZE, i * GRID)
      context.stroke
    end
  end

  def self.draw_symbols(arr, context)
    context.set_source_rgb(0, 0, 0)
    9.times do |i|
      draw_circle(i, context) if arr[i] == 1
      draw_x(i, context) if arr[i] == 2
    end
  end

  def self.draw_state(arr, context)
    context.set_source_rgb(1, 1, 1)
    context.paint
    draw_grid(context)
    draw_symbols(arr, context)
  end

  def self.colorstop(value, pattern)
    if value > 0
      pattern.add_color_stop(0.0, 1, 1 - value, 1 - value)
    else
      pattern.add_color_stop(0.0, 1 + value, 1 + value, 1)
    end
    pattern.add_color_stop(1.0, 1, 1, 1)
  end

  def self.puts_prob(pos, value, context)
    x, y = pos2grid(pos)
    context.move_to(x - 15, y - 10)
    context.set_source_rgb(0, 0, 0)
    context.font_size = 15
    context.show_text(format("%.2f", value))
  end

  def self.draw_prob(prob, arr, context)
    9.times do |i|
      next if arr[i] != 0
      x, y = pos2grid(i)
      pattern = Cairo::RadialPattern.new(x, y, 0, x, y, SYMBOL)
      colorstop(prob[i], pattern)
      context.set_source(pattern)
      context.circle(x, y, SYMBOL)
      context.fill
      context.stroke
      puts_prob(i, prob[i], context)
    end
  end

  def self.save_state(filename, arr)
    surface = Cairo::ImageSurface.new(Cairo::FORMAT_RGB24, SIZE, SIZE)
    context = Cairo::Context.new(surface)
    draw_state(arr, context)
    surface.write_to_png(filename)
    puts "Save to #{filename}"
  end

  def self.save_state_withprob(filename, arr, prob)
    surface = Cairo::ImageSurface.new(Cairo::FORMAT_RGB24, SIZE, SIZE)
    context = Cairo::Context.new(surface)
    draw_state(arr, context)
    draw_prob(prob, arr, context)
    surface.write_to_png(filename)
    puts "Save to #{filename}"
  end
end
