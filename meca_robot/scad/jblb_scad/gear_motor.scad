include <BOSL2/std.scad>
include <BOSL2/gears.scad>

mod = 1; // Gear module
teeth_gear_motor = 30; // Number of teeth of motor gear
	difference() {
		w = 5;
		spur_gear(
				mod=mod, teeth=teeth_gear_motor, thickness=w, helical=30,
				herringbone=true, slices=$preview?5:200
				);
        cuboid([6,6,6]);
    }
