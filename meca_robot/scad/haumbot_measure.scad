include <haumbot_tools.scad>
use <haumbot_extparts.scad>
use <haumbot_components.scad>

display = 0; // [0: Assembly, 1: Wheel, 2: Base]
switch(display) {
	measure_assembly();
	measure_wheel();
	measure_base();
}

module T_measure() T(y=15, rx=90+20) children();
module T_measure_clip() T(z=4) children();

module measure_wheel() tag_scope() diff() {
	wdim = washer_M8_A_dim();
	mdim = as5600_magnet_dim();
	tdim = tire_dim();

	tire_od = tdim[0];
	tire_id = tdim[1];
	tire_th = (tire_od - tire_id)/2;

	rim_dth = 0.5;
	rim_th = 4.4;

	axis_A_d = wdim[0] + 2;
	axis_A_h = 6;

	axis_B_d = wdim[0] - 0.1;
	axis_B_h = axis_A_h + (wdim[2] + 0.8)*2;

	spokes_d = 2;
	spokes_len = (tire_od - rim_th*3+rim_th*2 - axis_A_d) / 2;

	axis_hole_d = 3.2;

	// Rim
	torus(od=tire_od-tire_th/2+rim_dth, id=tire_od-tire_th*3+rim_dth); // Wheel outline
	rm() torus(od=tire_od+rim_dth, id=tire_id+rim_dth); // Slot

	// Spokes
	zrot_copies(n=7, d=axis_A_d-0.2) T(x=-1) xcyl(h=spokes_len+1.8, d1=spokes_d+1, d2=spokes_d, anchor=LEFT);

	// Axis
	zcyl(d=axis_A_d, h=axis_A_h, rounding=0.5); // Wheel axis part A
	zcyl(d=axis_B_d, h=axis_B_h, rounding=0.5); // Wheel axis part B

	// Magnet holder
	rm() T(z=axis_B_h/2+eps) zcyl(d1=mdim[0], d2=mdim[0]+0.2, h=mdim[1]+0.5, chamfer2=-0.8, anchor=TOP);
 
	// Axis hole (to remove magnet)
	rm() zcyl(h=axis_B_h+eps, d=axis_hole_d);

	// Nut trap, probably useless though
	T(z=-axis_B_h/2-eps) nut_trap_inline(1.8, "M3", $slop=.1, anchor=BOTTOM);
}

module board_holder() tag_scope() diff() {
	// Body
	T(z=-1) linear_extrude(2) difference() {
			hull() {
				xcopies(16.6, 2) ycopies(16.6, 2) circle(d=8);
				T(y=4) xcopies(30, 2) circle(d=4);
		}
		circle(d=20); // Inside big hole
	}

	// Holes
	zrot_copies(n=4, sa=45, d=sqrt(2)*(20-3.5)) {
		zcyl(d=6, h=2);
		rm() T(z=2) screw_hole("M3", l=6, anchor=TOP);
	}
}

module measure_base_shape() {
	rect([50,38], rounding=6);
}

module measure_base() {
	difference() {
		linear_extrude(3) measure_base_shape(); // Base
		zrot_copies(n=2) T_measure() {
			cuboid([26, 20, 10.5]); // Hole for clips
			cuboid([45, 10, 5.4], except=[BACK, FRONT], rounding=2.5); // Hole for wheels
			zcyl(h=10, d=20, anchor=BOTTOM); // Hole in front of PCB holder
			T(z=11) cuboid([25, 25, 7]); // Hole for measuring PCB
		}
		T(x=21, z=-eps) zcyl(d=3.4, h=3+2*eps, anchor=BOTTOM); // Weight option holes
	}

	// Clips and PCB holders
	zrot_copies(n=2) T_measure() {
		difference() {
			zflip_copy() T_measure_clip() T(rz=-90) washer_clip(washer_M8_A_dim()); // Clips
			xflip_copy() T(-8.25, 8.25, 4) zcyl(d=6.2, h=3); // Holes for measure PCB screws head
		}
		T_measure_clip() T(z=4) board_holder(); // PCB holder
	}
	xcopies(26, 2) T(z=-7) prismoid(size1=[2, 17], size2=[2, 10], h=11, anchor=BOTTOM); // Holder reinforcement bars
	yflip_copy() T_measure() xflip_copy() T(x=-11.5, y=1) zflip_copy() T_measure_clip() difference() { // Exterior clips reinforcement
		cuboid([13,6,2.6], rounding=2, edges=[BACK+LEFT, FRONT+LEFT], anchor=RIGHT+FRONT);
		cuboid([2,5,3], anchor=RIGHT+FRONT);
	}
	yflip_copy() T_measure() T(x=23.5, y=4) cuboid([1.5,3.8,6]); // Exterior clips reinforcement bridge

	// Loop for wires
	T(x=-26, y=0, z=4.5, ry=25) left_half(x=2) torus(id=14, od=14+6);

	// Pivot bars
	yflip_copy() difference() {
		chain_hull() { // Bars
			T(x=-31.7, y=24, z=3.9) ycyl(h=3, d=6);
			T(x=-31.7+6, y=24, z=3.9) ycyl(h=3, d=6);
			T(x=-23.5, y=0, z=3) sphere(d=3);
		}
		T(x=-31.7, y=24, z=3.9) ycyl(h=3+eps, d=3.2); // Holes
	}
}

module measure_assembly() {
	measure_base();
	zrot_copies(n=2) T_measure() {
		measure_wheel();
		color("#ffcc0080") T(z=9, ry=180, rz=90) as5600_board();
		color("#ffcc0080") T(8.3, 8.3, 9, rx=180) screw("M3", head="button", l=6);
		color("#ffcc0080") T(8.3, 8.3, 10.5) nut("M3");
		color("#000") tire();
		zflip_copy() color("#ccc") T_measure_clip() washer_M8_A();
		zflip_copy() T_measure_clip() zrot(-90) washer_clip_cap(washer_M8_A_dim());
	} 
}
