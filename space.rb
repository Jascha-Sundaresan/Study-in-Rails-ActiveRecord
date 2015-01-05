module Emu
  #thruster
  #cannons
  #cargo bays
  def fire_egg_cannon
    puts "pop pop pop goes the egg cannon"
  end

  def fire_photon_cannon
    puts "pop pop pop goes the photon cannon"
  end

  def fire_all_cannons
    fire_photon_cannon
    fire_egg_cannon
  end

  def set_leg_thruster val
    @leg_thruster = val
    puts "setting leg thruster to #{val}%"
  end

  def set_flap_thruster val
    @flap_thruster = val
    puts "setting flap thruster to #{val}%"
  end

  def store_in_pouch_bay stuff
    central_bay[:pouch] = stuff
  end

  def store_in_stomach_bay stuff
    central_bay[:stomach] = stuff
  end

  def unload_cargo
    cargo = central_bay.values
    @central_bay = {} 
    cargo
  end

  def central_bay
    @central_bay ||= {}
  end

end

class Hummingbird
  include Emu
end

class SpaceBase
  def self.weird_shit
    @@shit ||= []
  end
  def weird_shit
    @@shit ||= []
  end
  def self.fleet
    @fleet ||= []
  end

  def initialize
    self.class.fleet << self
  end
end

module Cargoable
  def install_cargo_bays *bay_names
    define_method "central_bay" do
      @central_bay ||= {}
    end
    bay_names.each do |bay_name|
      define_method "store_in_#{bay_name}_bay" do |stuff|
        puts "storing #{stuff} in #{bay_name} bay"
        central_bay[bay_name] = stuff
      end
    end
    define_method "unload_cargo" do
      cargo = central_bay.values
      @central_bay = {}
      cargo
    end
  end

end
module Thrusterable
  def mount_thruster thruster_name
    define_method "set_#{thruster_name}_thruster" do |val|
      ivar_name = "@#{thruster_name}_thruster"
      instance_variable_set(ivar_name, val)
      puts "thruster #{thruster_name} set to #{instance_variable_get(ivar_name)}%"
      #set instance variable to val
      #print status
    end
  end
end

module Cannonable
  def attach_cannons options
    #build all the sweet ass cannon methods
    options.each do |name, sound|
      define_method "fire_#{name}_cannon" do
        puts sound * 3 + " goes the #{name} cannon"
      end
    end

    define_method "fire_all_cannons" do
      options.keys.each { |name| self.send("fire_#{name}_cannon") }
    end
  end
end

class AlduranShipBase < SpaceBase
  extend Thrusterable
  extend Cargoable
end

class Dodo < AlduranShipBase
  mount_thruster :wing
  install_cargo_bays :beak, :small_intestine, :east, :gall_bladder
end
class Dodo2 < Dodo

end













