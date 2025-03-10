include <BOSL2/std.scad>
include <BOSL2/gears.scad>

mod = 1; // Gear module
teeth_gear_wheel = 15; // Number of teeth of wheel gear
difference() {
	spur_gear(
			mod=mod, teeth=teeth_gear_wheel, thickness=5, helical=-30,
			herringbone=true, slices=$preview?5:200
			);
    cuboid([6,6,6]);
}