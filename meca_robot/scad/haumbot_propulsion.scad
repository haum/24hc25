include <haumbot_tools.scad>
use <haumbot_extparts.scad>
use <haumbot_components.scad>

display = 0; // [0: Assembly L, 1: Assembly R, 2: Gear Motor, 3: Gear Motor FDM main, 4: Gear Motor FDM axis, 5: Gear wheel, 6: Gear wheel FDM main, 7: Gear wheel FDM axis, 8: Wheel, 9: Bracket L, 10: Bracket R]
switch(display) {
propulsion_assembly();
	propulsion_assembly(true);
	gear_motor();
	gear_motor_fdm_main();
	gear_motor_fdm_axis();
	gear_wheel();
	gear_wheel_fdm_main();
	gear_wheel_fdm_axis();
	propulsion_wheel();
	propulsion_bracket();
	propulsion_bracket(true);
}

mod = 1; // Gear module
teeth_gear_motor = 30; // Number of teeth of motor gear
teeth_gear_wheel = 15; // Number of teeth of wheel gear
d_gears = gear_dist(mod=mod, teeth_gear_motor, teeth_gear_wheel, helical=30); // Distance between the gears

module axis(a=-1, b1=-1, b2=-1) {
	wdim = washer_M6_A_dim();

	aa = a < 0 ? 4 : a;
	bb1 = b1 < 0 ? wdim[2]+1.5 : b1;
	bb2 = b2 < 0 ? wdim[2]+1.5 : b2;

	axis_A_d = wdim[0] + 2;
	axis_A_h = aa;

	axis_B_d = wdim[0] - 0.1;
	axis_B_h = axis_A_h + bb1 + bb2;

	zcyl(d=axis_A_d, h=axis_A_h, rounding=0.5); // Wheel axis part A
	T(z=(bb1-bb2)/2) zcyl(d=axis_B_d, h=axis_B_h, rounding=0.5); // Wheel axis part B
}

module gear_motor_plain() {
	spur_gear(
		mod=mod, teeth=teeth_gear_motor, thickness=5, helical=30,
		herringbone=true, slices=$preview?5:200
	);
}

module gear_motor_fdm_main() {
	difference() {
		gear_motor_plain();
		cuboid([9.1, 9.1, 6]);
	}
}

module gear_motor_fdm_axis(fdm=true) tag_scope() diff() {
	difference() {
		axis(6.5, 0, -1);
		T(z=3) zcyl(d=6, h=3); // Remove part of axis to reveal servo attach teeth
	}
	T(z=-8) screw_hole("M3", l=13, anchor=BOTTOM); // Axis hole

	// Servo attach teeth
	T(z=1) servo_attach();

	if (fdm) {
		difference() {
			cuboid([9, 9, 5]);
			zcyl(h=6, d=6);
		}
	}
}

module gear_motor() tag_scope() diff() {
	// Hollow gear
	difference() {
		gear_motor_plain();
		zcyl(d=30, h=6);
	}

	// Axis
	gear_motor_fdm_axis(false);

	// Spokes
	zrot_copies(n=9) T(x=-4) {
		xcyl(d=2, h=12, anchor=RIGHT);
		T(x=-11+2) xcyl(d1=5, d2=2, h=2, anchor=RIGHT);
		xcyl(d1=2, d2=5, h=2, anchor=RIGHT);
	}
}

module gear_wheel_plain() {
	spur_gear(
		mod=mod, teeth=teeth_gear_wheel, thickness=5, helical=-30,
		herringbone=true, slices=$preview?5:200
	);
}

module gear_wheel_fdm_main() {
	difference() {
		gear_wheel_plain();
		cuboid([9.1, 9.1, 6]);
	}
}

module gear_wheel_fdm_axis(fdm=true) tag_scope() diff() {
	axis(a=6.5);
	T(z=-10) screw_hole("M3", l=17, anchor=BOTTOM);

	if (fdm) {
		difference() {
			cuboid([9, 9, 5]);
			zcyl(h=6, d=6);
		}
	}
}

module gear_wheel() {
	difference() {
		gear_wheel_plain();
		zcyl(h=6, d=6);
	}
	gear_wheel_fdm_axis();
}

module propulsion_wheel() tag_scope() diff() {
	tdim = [40, 35.2];

	tire_od = tdim[0];
	tire_id = tdim[1];
	tire_th = (tire_od - tire_id)/2;

	rim_dth = 0.5;
	rim_th = 4.4;

	axis_A_d = 11;
	axis_A_h = 5;

	axis_B_d = 9;
	axis_B_h = 4.5;

	spokes_d = 2;
	spokes_len = (tire_od - rim_th*3+rim_th*2 - axis_A_d) / 2;

	axis_hole_d = 3.4;
	axis_hole_d2 = 6.2;

	// Rim
	zcopies(3,2) {
		torus(od=tire_od-tire_th/2+rim_dth, id=tire_od-tire_th*3+rim_dth); // Wheel outline
		rm() torus(od=tire_od+rim_dth, id=tire_id+rim_dth); // Slot
	}
	tube(od=tire_id+tire_th, id=tire_id, h=5);

	// Spokes
	zrot_copies(n=9, d=axis_A_d-0.2) T(x=-1) xcyl(h=spokes_len+1.8, d1=spokes_d+1, d2=spokes_d, anchor=LEFT);

	// Axis
	zcyl(d=axis_A_d, h=axis_A_h, rounding=0.5); // Wheel axis part A
	T(z=axis_A_h/2) zcyl(d=axis_B_d, h=axis_B_h, rounding2=0.5, anchor=BOTTOM); // Wheel axis part B

	// Axis hole
	T(z=-axis_A_h/2-eps) rm() zcyl(h=axis_A_h+axis_B_h+2*eps, d=axis_hole_d, anchor=BOTTOM);
	T(z=-axis_A_h/2-eps) rm() zcyl(h=axis_A_h+axis_B_h+2*eps-4, d=axis_hole_d2, rounding1=-0.5, anchor=BOTTOM);
}

module T_motor_gear() T(y=d_gears+0.2) children();
module T_propulsion_clip() T(z=-4.2) children();

module propulsion_bracket_frame(r=false) tag_scope() diff() {
	c = [-26, -6, d_gears+13]; // Triangle sizes
	a = -atan2(c[2]-c[1], c[0]); // Angle of hypotenuse

	// Triangle
	T(x=-13, z=-11/2) linear_extrude(11) {
		difference() {
			hull() {
				T(x=c[0], y=c[1]) circle(7);
				T(y=c[1]) circle(7);
				T(y=c[2]) circle(7);
			}
			hull() {
				T(x=c[0], y=c[1]) circle(2);
				T(y=c[1]) circle(2);
				T(y=c[2]) circle(2);
			}
		}
	}

	// Gears clearance space
	rm() zcyl(h=6, d=24); // Wheel gear clearance
	rm() T_motor_gear() zcyl(h=6, d=42); // Motor gear clearance

	// Servomotor holder
	T(x=-5.5, z=r?-9-3.5:3.5) T_motor_gear() difference() {
		cuboid([36, 17, 9], rounding=2, anchor=BOTTOM); // Body
		T(z=-eps) cuboid([23, 12.2, 9+2*eps], chamfer=-0.5, anchor=BOTTOM); // Servo body hole
		xcopies(28, 2) zcyl(d=1.5, h=12+eps, anchor=BOTTOM); // Servo screws holes
		xflip_copy() T(x=-14, y=7, z=4.5) cuboid([3.4, 5, 5]); // Additional hooking holes
	}
	rm() T(x=-5.5, z=(r?-1:1)*4-eps) T_motor_gear() cuboid([23, 12.2, 9.5+2*eps], anchor=r?TOP:BOTTOM); // Cut triangle to allow servo to pass

	// Attach on servo holder
	T(x=-5.5, z=(r?-9-3.5:3.5)+4.5) T_motor_gear() T(x=36/2+4, ry=90) difference() {
		union() { // Body
			cuboid([3,6,3], rounding=2, edges=[TOP+FRONT, TOP+BACK], anchor=BOTTOM);
			cuboid([3,6,4], rounding=-1, edges=BOTTOM, anchor=TOP);
		}
		xcyl(h=5, d=3.4); // Hole
	}

	// Measure pivot
	T(x=-13+c[0], rx=-90-a, ry=90, tx=r?6:-6, ty=6, tz=5) difference() {
		union() { // Body
			cuboid([3,6,3], rounding=2, edges=[TOP+FRONT, TOP+BACK], anchor=BOTTOM);
			cuboid([3,6,6], rounding=2, edges=[BOTTOM+(r?RIGHT:LEFT)], anchor=TOP);
		}
		xcyl(h=5, d=3.2); // Hole
	}

	// Bottom plate attach zone
	xcopies(10, 2) T(x=-13+c[0]/2, y=-13+5-eps) ycyl(h=2, d=2, anchor=FRONT); // Centering pins
	rm() xcopies(10, 3) T(x=-13+c[0]/2, y=-13-eps) { // Mounting holes on bottom
		ycyl(h=7, d=3.4, anchor=FRONT);
		ycyl(h=3, d=7, anchor=FRONT);
	}

	// Mounting holes on hypotenuse
	rm() T(x=-13+c[0]/2, y=(c[2]+c[1])/2, rz=a, tx=5, ty=-7-eps) xcopies(10, 4) {
		ycyl(h=7, d=3.4, anchor=FRONT);
		T(rx=90, tz=-5.2) nut_trap_inline(3, "M3", $slop=0.1, anchor=BOTTOM);
	}
}

module propulsion_bracket(r=false) {
	module R() T(rx=r?180:0) children();

	propulsion_bracket_frame(r);
	zflip_copy() T_propulsion_clip() washer_clip(washer_M6_A_dim());
	T_motor_gear() R() T_propulsion_clip() washer_clip(washer_M6_A_dim());
}

module propulsion_assembly_nobracket(r=false) {
	module R() T(rx=r?180:0) children();

	// Gears
	T(rz=(r?0:180)/teeth_gear_wheel) R() gear_wheel();
	T_motor_gear() R() gear_motor();

	// Washers
	zflip_copy() T_propulsion_clip() color("#ccc") washer_M6_A();
	T_motor_gear() R() T_propulsion_clip() color("#ccc") washer_M6_A();

	// Clip caps
	zflip_copy() T_propulsion_clip() washer_clip_cap(washer_M6_A_dim());
	T_motor_gear() R() T_propulsion_clip() washer_clip_cap(washer_M6_A_dim());

	// Wheel
	R() T(z=-13) {
		propulsion_wheel();
		color("#000") zcopies(3, 2) tire();
	}

	// Wheel screw
	R() T(tz=0.8, rx=180) color("#ffcc0080") screw("M3", head="button", length=20);
	R() T(tz=-8.8, rx=180) color("#ffcc0080") nut("M3");

	// Servo
	T_motor_gear() R() T(z=4.5, rx=90, rz=180) color("#ffcc0080") servomotor();

	// Bottom screw
	xcopies(10, 3) T(x=-26, y=-7, rx=90) color("#ffcc0080") screw("M3", head="button", length=10);
	xcopies(10, 3) T(x=-26, y=-2, rx=90) color("#ffcc0080") nut("M3");
}

module propulsion_assembly(r=false) {
	propulsion_bracket(r);
	propulsion_assembly_nobracket(r);
}
