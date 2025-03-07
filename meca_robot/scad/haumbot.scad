include <haumbot_tools.scad>
use <haumbot_extparts.scad>
use <haumbot_components.scad>
use <haumbot_measure.scad>
use <haumbot_propulsion.scad>

show_max_volume_cube = false;
show_max_volume_cylinder = false;

display = 0; // [0: Assembly, 1: Base shape, 2: Plate base shape, 3: Back shape, 4: Back plate, 5: Front structure]
switch(display) {
	assembly();
	base_shape();
	plate() base_shape();
	back_shape();
	plate() back_shape();
	front_structure();
}

if (show_max_volume_cube)
	%T(x=-17, z=-40/2) cuboid([100,100,80], anchor=BOTTOM);
if (show_max_volume_cylinder)
	%T(z=-40/2) zcyl(h=80, d=120, anchor=BOTTOM);

module T_propulsion(r=false) T(y=r?-33:33, rx=90) children();

module base_shape() {
	difference() {
		hull() { // Base shape
			T(x=-40) rect([65, 77], rounding=3, anchor=LEFT);
			T(x=5) circle(d=70);
		}
		yflip_copy() T(x=-11.5, y=77/2+eps) rect([22, 11.2], rounding=[-3, -3, 1, 1], anchor=BACK+LEFT); // Sides holes
		hull() { // Measure wheels hole
			rect([50+4,36+4], rounding=6);
			xcopies(20,2) ycopies(38, 2) circle(d=8);
		}
		T(x=-26) ycopies(77-11, 2) { // Bracket mounting
			xcopies(10, 2) circle(d=2.3);
			xcopies(10, 3) circle(d=3.4);
		}
		T(x=21) ycopies(77-11, 2) circle(d=3.4); // Font side mounting holes
		T(x=30) ycopies(40, 2) circle(d=3.4); // Font mounting holes
		T(x=35) rect([3, 18], rounding=1.5); // Slot for telemeter
	}
}

module back_shape() {
	difference() {
		union() { // Base shape
			hull() { // Main
				T(x=-20/sin(120)+10) rect([65, 77], rounding=3, anchor=LEFT);
				T(x=65) circle(d=40);
			}
			T(x=-20/sin(120)+5, rz=90) rect([10, 10], rounding=[3, 3, -3, -3]); // Leg
		}
		T(x=30) xcopies(15, 2) circle(d=10); // cable holes
		T(x=18) ycopies(66, 2) xcopies(10, 4) circle(d=3.4); // Mounting holes
		T(x=65) circle(d=30); // Hook hole
	}
}

module front_structure() {
	module p() T(x=25, y=12, z=15) sphere(d=4);
	module T_hole_sensor() T(x=35-3/2-1.5/2, y=10, z=0.5) children();
	module T_hole_side() T(x=21, y=33, z=-3.5) children();
	module T_hole_front() T(x=30, y=20, z=-3.5) children();
	module T_hole_top() T(x=16.5, y=22, z=26.2) children();

	// Central bar
	hull() {
		p();
		yflip() p();
	}

	// Mirrored sides
	tag_scope() diff() yflip_copy() {
		// Bottom front leg
		chain_hull() {
			T_hole_front() zcyl(d=6, h=3);
			T_hole_front() T(rz=-80, tx=5) zcyl(d=4, h=3);
			T_hole_sensor() T(x=-3) xcyl(d=7, h=3);
			p();
		}
		T_hole_sensor() xcyl(d=6, h=3);
		T_hole_sensor() rm() xcyl(d=3.4, h=20);
		T_hole_sensor() T(x=-7, ry=90) rm() nut_trap_inline(5, "M3", $slop=0.1, anchor=BOTTOM);
		T_hole_front() rm() zcyl(d=3.4, h=4);

		// Side leg
		chain_hull() {
			T_hole_side() zcyl(d=6, h=3);
			T_hole_side() T(rz=-135, tx=5) zcyl(d=4, h=3);
			p();
		}
		T_hole_side() rm() zcyl(d=3.4, h=4);

		// Top arm
		chain_hull() {
			T_hole_top() ycyl(d=6, h=3);
			T_hole_top() T(ry=90, tx=5) ycyl(d=4, h=3);
			p();
		}
		T_hole_top() rm() ycyl(d=3.4, h=4);
	}
}

module assembly() {
	module T_backplane() T(x=-43.5, ry=180+120.029, tz=3) children();
	
	T(z=-8) linear_extrude(3) base_shape();
	T_backplane() T(z=-3) linear_extrude(3) back_shape();
	front_structure();

	T_propulsion() propulsion_bracket();
	T_propulsion(true) propulsion_bracket(true);
	T_propulsion() propulsion_assembly_nobracket();
	T_propulsion(true) propulsion_assembly_nobracket(true);
	T(z=-(1-cos(20))*20) measure_assembly();

	T_backplane() T(x=-1.5, rz=90) color("#ffcc0080") battery_holder();
	T_backplane() T(x=30, y=-18, z=1) color("#ffcc0080") battery_charger();
	T_backplane() T(x=30, y=18, z=1) color("#ffcc0080") esp_controller();
	T(x=35, z=0.5, rz=90) T(rx=90) color("#ffcc0080") vl53l3cx();
}
