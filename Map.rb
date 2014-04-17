require 'rubygems'
require 'gosu'
#require_relative 'Sprite'
include Gosu

module Tiles
  Wall = 1
end

class Map
  attr_reader :width, :height, :tilesize
  def initialize(window, filename)
    #Loads 20x20 pix tileset
    @tileset = Image.load_tiles(window, "media/Test Tileset.png", 20, 20, true)
    @tilesize = 15
    #Reads map.txt line by line and turns it into tiles
    lines = File.readlines(filename).map { |line| line.chomp }
    @height = lines.size
    @width = lines[0].size
    @tiles = Array.new(@width) do |x|
      Array.new(@height) do |y|
        case lines[y][x]
          when '#'
            Tiles::Wall
          else
            nil
        end
      end
    end
  end


  def draw
    @height.times do |y|
      @width.times do|x|
        tile = @tiles[x][y]
        if tile
          @tileset[tile].draw(x*@tilesize, y*@tilesize, 0)
        end
      end
    end
  end

  def solid?(x, y)
    @tiles[x/@tilesize][y/@tilesize]
  end
end

class GameObject
  attr_reader :x, :y
  def initialize(window, x, y, image)
    @x, @y = x, y
    @map = window.map
    @tilesize = window.map.tilesize
    @dir = 3
  end
  #Checks Top right, Top left, Bottom right, and Bottom left corners for collision
  def isValid?(newx,newy)
    not @map.solid?(@x+newx, @y+newy)
  end
  def warp(newx, newy)
    @x, @y = newx, newy
  end
  def update(vx,vy)
    if vx > 0
      vx.times { if isValid?(vx+1,vy); @x+=vx; end}
    end
    if vx < 0
      (-vx).times { if isValid?(vx-1,vy); @x+=vx; end}
    end
    if vy > 0
      vy.times { if isValid?(vx,vy-2); @y-=vy; end}
    end
    if vy < 0
      (-vy).times { if isValid?(vx,vy+2); @y-=vy; end}
    end
  end
  def getcoord()
    return [@x, @y]
  end
  def getdir()
    return @dir
  end
  def setdir(bloop) #whichever direction you set it to
    @dir = bloop
  end
end

class Player < GameObject
  def initialize(window, x, y, image)
    super
    @image, @image2, @image3, @image4 = *Image.load_tiles(window, image, 15, 15, false)
  end
  def draw()
    @image.draw(@x, @y, 1, 1.0, 1.0)
  end
  def fail?(player_x, player_y, ghost_x, ghost_y)
    if player_x == ghost_x && player_y == ghost_y
      
    end
  end
end

class Ghost < GameObject
  def initialize(window, x, y, image)
    super
    @image, @image2, @image3, @image4 = *Image.load_tiles(window, image, 15, 15, false)
    @count = 0
  end
  def draw()
    @image.draw(@x, @y, 1, 1.0, 1.0)
  end
  def getcount()
    return @count
  end
  def addcount()
    @count += 1
  end
  def clearcount()
    @count = 0
  end
  
end

class Game < Window
  attr_reader :map
  def initialize
    super 720, 540, false
    self.caption = "Honors Project"
    @map = Map.new(self, "media/map2.txt")
    @background = Image.new(self, "media/Space.png", true)
    @player = Player.new(self, 255, 360, "media/Test Sprite.png")
    @ghost = Ghost.new(self, 100, 227, "media/Test Sprite Enemy.png")
  end

  def draw
    @background.draw 0,0,0
    @map.draw
    @player.draw
    @ghost.draw
  end

  def update
    vx = vy = 0
    
    vx += 1 if button_down? KbRight
    vx -= 1 if button_down? KbLeft
    vy += 1 if button_down? KbUp
    vy -= 1 if button_down? KbDown
    @player.update(vx, vy)
    
    dir = @ghost.getdir()
    ghostcoord = @ghost.getcoord()
    gx = ghostcoord[0]
    gy = ghostcoord[1]
    if @ghost.getcount() != 0
      @ghost.addcount()
      if @ghost.getcount() == 16
        @ghost.clearcount()
      end
      if dir == 3
        @ghost.update(1, 0) #going to the right
      elsif dir == 2
        @ghost.update(-1, 0) #going to the left
      elsif dir == 0
        @ghost.update(0, -1) #take it back now yall (down)
      elsif dir == 1
        @ghost.update(0, 1) #going up
      else 
        @ghost.update(0, 0) 
      end
      @ghost.setdir(dir)
      return
    end
    posdir= Array.new
    if @ghost.isValid?(gx + 15, gy) && dir !=2
      posdir.push(3)  
    end
    if @ghost.isValid?(gx-1, gy) && dir != 3
      posdir.push(2)
    end
    if @ghost.isValid?(gx, gy+15) && dir !=1
      posdir.push(0)
    end
    if @ghost.isValid?(gx, gy-1) && dir != 0
      posdir.push(1)
    end

    tempdir = posdir.sample
    if tempdir == 3
      @ghost.update(1, 0) #going to the right
    elsif tempdir == 2
      @ghost.update(-1, 0) #going to the left
    elsif tempdir == 0
      @ghost.update(0, -1) #take it back now yall (down)
    elsif tempdir == 1
      @ghost.update(0, 1) #going up
    else 
      @ghost.update(0, 0) 
    end
    @ghost.setdir(tempdir)
    if tempdir != dir
      @ghost.addcount()
    end
          #puts playercoord
    
  end
end

#  def button_down(id)
#    if id == KbEscape then close end
#  end

window = Game.new
window.show