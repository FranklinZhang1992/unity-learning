require 'singleton'

  def volume() Volume.instance end
  def disk_image() DiskImage.instance end
  def local_image_container() LocalImageContainer.instance end

def max(params)
  max_param = params[0]
  params.each do |param|
    max_param = param if param > max_param
  end
  max_param
end

def min(params)
  min_param = params[0]
  params.each do |param|
    min_param = param if param < max_param
  end
  min_param
end

def sum(params)
  total = 0
  params.each do |param|
    total += param
  end
  total
end

class Volume
  include Singleton
  attr_accessor :cannot_snapshot
  attr_accessor :insufficient_free_space_to_snapshot
  def initialize
  self.cannot_snapshot = false
  self.insufficient_free_space_to_snapshot = false
  end
  def set_cannot_snapshot(value)
    self.cannot_snapshot = value
    if self.cannot_snapshot == true
      puts "cannot snapshot"
    end
  end
  def set_insufficient_free_space_to_snapshot(value)
    self.insufficient_free_space_to_snapshot = value
    set_cannot_snapshot(self.insufficient_free_space_to_snapshot)
  end
end

class DiskImage
  include Singleton
  attr_accessor :insufficient_free_space_to_snapshot
  attr_accessor :free_space_needed_to_snapshot
  attr_accessor :writable_size
  attr_accessor :growth_size
  attr_accessor :extra_free_space_needed_to_snapshot
  attr_accessor :required_size
  attr_accessor :used_size
  attr_accessor :virtual_size
  attr_accessor :overhead_size
  attr_accessor :free_space_needed_for_merge
  attr_accessor :free_space_needed_for_commit
  def initialize
    self.insufficient_free_space_to_snapshot = 0
    self.free_space_needed_to_snapshot = 0
    self.writable_size = 0
    self.growth_size = 0
    self.extra_free_space_needed_to_snapshot = 0
    self.required_size = 0
    self.used_size = 0
    self.virtual_size = 0
    self.overhead_size = 0
    self.free_space_needed_for_merge = 0
    self.free_space_needed_for_commit = 0
  end
  def show
    msg = "insufficient_free_space_to_snapshot = #{self.insufficient_free_space_to_snapshot}\n"
    msg += "free_space_needed_to_snapshot = #{self.free_space_needed_to_snapshot}\n"
    msg += "writable_size = #{self.writable_size}\n"
    msg += "growth_size = #{self.growth_size}\n"
    msg += "extra_free_space_needed_to_snapshot = #{self.extra_free_space_needed_to_snapshot}\n"
    msg += "required_size = #{self.required_size}\n"
    msg += "used_size = #{self.used_size}\n"
    msg += "virtual_size = #{self.virtual_size}\n"
    msg += "overhead_size = #{self.overhead_size}\n"
    msg += "free_space_needed_for_merge = #{self.free_space_needed_for_merge}\n"
    msg += "free_space_needed_for_commit = #{self.free_space_needed_for_commit}\n"
    puts "DiskImage:\n#{msg}\n\n"
  end
  def set_insufficient_free_space_to_snapshot(value)
    self.insufficient_free_space_to_snapshot = value
    if self.insufficient_free_space_to_snapshot == true
      volume.set_insufficient_free_space_to_snapshot(true)
    else
      volume.set_insufficient_free_space_to_snapshot(false)
    end
  end
  def do_size_trigger
    required_size = self.free_space_needed_to_snapshot.to_i
    free_size = local_image_container.free_size.to_i
    puts "do_size_trigger: required_size = #{required_size}, free_size = #{free_size}"
    if required_size > free_size
      set_insufficient_free_space_to_snapshot(true)
    end
  end
  def set_free_space_needed_to_snapshot(writable_size, growth_size, extra_size)
    writable_size = writable_size.to_i
    growth_size = growth_size.to_i
    extra_size = extra_size.to_i
    puts "set_free_space_needed_to_snapshot: writable_size = #{writable_size}, growth_size = #{growth_size}, extra_size = #{extra_size}"
    required_size = writable_size + extra_size
    if required_size > growth_size
      self.free_space_needed_to_snapshot = required_size - growth_size
    else
      self.free_space_needed_to_snapshot = 0
    end
    do_size_trigger
  end
  def set_growth_size(writable_size, used_size)
    writable_size = writable_size.to_i
    used_size = used_size.to_i
    if writable_size > used_size
      self.growth_size = writable_size - used_size
    else
      self.growth_size = 0
    end
    set_free_space_needed_to_snapshot(self.writable_size, self.growth_size, self.extra_free_space_needed_to_snapshot)
  end
  def set_writable_size(value)
    value = value.to_i
    self.writable_size = value
    set_growth_size(self.writable_size, self.used_size)
    set_free_space_needed_to_snapshot(self.writable_size, self.growth_size, self.extra_free_space_needed_to_snapshot)
  end
  def set_virtual_size(value)
    value = value.to_i
    self.virtual_size = value
    set_writable_size(self.virtual_size)
  end
  def set_free_space_needed_for_merge(free_space_needed_for_commit)
    free_space_needed_for_commit = free_space_needed_for_commit.to_i
    params = []
    params << 0 # free_space_needed_for_pull
    params << free_space_needed_for_commit
    self.free_space_needed_for_merge = max(params)
    local_image_container.set_free_space_needed_for_merge(self.free_space_needed_for_merge)
  end
  def set_free_space_needed_for_commit(used_size)
    used_size = used_size.to_i
    params = []
    params << used_size # self(dependsOn:$bottomDiskImage != nil, usedSize:$space) & DiskImage(guidKey:$bottomDiskImage)
    volume_size = self.virtual_size
    bottom_disk_image_used_size = self.used_size
    params << volume_size - bottom_disk_image_used_size
  end
  def set_used_size(value)
    value = value.to_i
    self.used_size = value
    set_free_space_needed_for_commit(self.used_size)
  end
  def load_disk_image(virtual_size, used_size)
    set_virtual_size(virtual_size)
    set_used_size(used_size)
  end
end

class LocalImageContainer
  include Singleton
  attr_accessor :free_size
  attr_accessor :reported_free_size
  attr_accessor :reserved_size
  attr_accessor :logical_size
  attr_accessor :reported_used_size
  attr_accessor :growth_size
  attr_accessor :overhead_size
  attr_accessor :free_space_needed_for_merge
  attr_accessor :create_reserved_size
  attr_accessor :resize_reserved_size
  attr_accessor :snapshot_reserved_size
  def initialize
    self.free_size = 0
    self.reported_free_size = 0
    self.reserved_size = 0
    self.logical_size = 0
    self.growth_size = 0
    self.overhead_size = 0
    self.free_space_needed_for_merge = 0
    self.create_reserved_size = 0
    self.resize_reserved_size = 0
    self.snapshot_reserved_size = 0
  end
  def show
    msg = "free_size = #{self.free_size}\n"
    msg += "reported_free_size = #{self.reported_free_size}\n"
    msg += "reserved_size = #{self.reserved_size}\n"
    msg += "logical_size = #{self.logical_size}\n"
    msg += "reported_used_size = #{self.reported_used_size}\n"
    msg += "growth_size = #{self.growth_size}\n"
    msg += "overhead_size = #{self.overhead_size}\n"
    msg += "free_space_needed_for_merge = #{self.free_space_needed_for_merge}\n"
    msg += "create_reserved_size = #{self.create_reserved_size}\n"
    msg += "resize_reserved_size = #{self.resize_reserved_size}\n"
    msg += "snapshot_reserved_size = #{self.snapshot_reserved_size}\n"
    puts "LocalImageContainer:\n#{msg}\n\n"
  end
  def set_free_size(reported_free_size, reserved_size)
    reported_free_size = reported_free_size.to_i
    reserved_size = reserved_size.to_i
    if reported_free_size > reserved_size
      self.free_size = reserved_size - reported_free_size
    else
      self.free_size = 0
    end
    disk_image.do_size_trigger
  end
  def set_reported_free_size(size, reported_used_size)
    size = size.to_i
    reported_used_size = reported_used_size.to_i
    if size > reported_used_size
      self.reported_free_size = size - reported_used_size
    else
      self.reported_free_size = 0
    end
    set_free_size(self.reported_free_size, self.reserved_size)
  end
  def set_logical_size(value)
    value = value.to_i
    self.logical_size = value
    set_reported_free_size(self.logical_size, self.reported_used_size)
  end
  def set_reported_used_size(value)
    value = value.to_i
    self.reported_used_size = value
    set_reported_free_size(self.logical_size, self.reported_used_size)
  end
  def set_reserved_size(growth_size, overhead_size, free_space_needed_for_merge, create_reserved_size, resize_reserved_size, snapshot_reserved_size)
    params = []
    params << growth_size.to_i
    params << overhead_size.to_i
    params << free_space_needed_for_merge.to_i
    params << create_reserved_size.to_i
    params << resize_reserved_size.to_i
    params << snapshot_reserved_size.to_i
    self.reserved_size = sum(params)
  end
  def load_image_container(logical_size, reported_used_size)
    set_logical_size(logical_size)
    set_reported_used_size(reported_used_size)
  end
  def set_free_space_needed_for_merge(value)
    value = value.to_i
    self.free_space_needed_for_merge = value
    set_reserved_size(self.growth_size, self.overhead_size, self.free_space_needed_for_merge, 0, 0, self.snapshot_reserved_size)
  end
  def set_growth_size(value)
    value = value.to_i
    self.growth_size = value
    set_reserved_size(self.growth_size, self.overhead_size, self.free_space_needed_for_merge, 0, 0, self.snapshot_reserved_size)
  end
  def set_overhead_size(value)
    value = value.to_i
    self.overhead_size = value
    set_reserved_size(self.growth_size, self.overhead_size, self.free_space_needed_for_merge, 0, 0, self.snapshot_reserved_size)
  end
  def set_snapshot_reserved_size(value)
    value = value.to_i
    self.snapshot_reserved_size = value
    set_reserved_size(self.growth_size, self.overhead_size, self.free_space_needed_for_merge, 0, 0, self.snapshot_reserved_size)
  end
end

class TopologyLoader
  def load
    virtual_size = 21054357504 # disk-image => virtual-size
    used_size = 65536 # disk-image => size
    logical_size =  21322088448 # local-image-container => logical-size
    reported_used_size = 46239744 # local-image-container => used-size

    # Begin load
    disk_image.load_disk_image(virtual_size, used_size)
    local_image_container.load_image_container(logical_size, reported_used_size)
    disk_image.show
    local_image_container.show
  end
end

begin
  loader = TopologyLoader.new
  loader.load
rescue Exception => e
  raise
end
