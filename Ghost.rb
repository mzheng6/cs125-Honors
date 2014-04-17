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
