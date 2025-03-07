include <haumbot_tools.scad>

display = 0; // [0: servomotor, 1: servo_attach, 2: as5600_board, 3: as5600_magnet, 4: esp_controller, 5: tire, 6: washer_M8_A, 7: washer_M6_A, 8: battery_holder, 9: battery_charger, 10: VL53L3CX]
switch(display) {
	servomotor();
	servo_attach();
	as5600_board();
	as5600_magnet();
	esp_controller();
	tire();
	washer_M8_A();
	washer_M6_A();
	battery_holder();
	battery_charger();
	vl53l3cx();
}


/** Servomotor **/

module T_servomotor_body_front() T(5.5, 4) children();
module T_servomotor_flap_front() T_servomotor_body_front() T(y=4) children();
module servomotor() tag_scope() diff() {
	// Rotor
	ycyl(h=3, d=4.8, anchor=BACK);

	// Rotor base
	ycyl(h=4, d=11.5, anchor=FRONT); // Large cylinder
	T(x=5.5) ycyl(h=4, d=5.5, anchor=FRONT); // Small cylinder

	// Body
	T_servomotor_body_front() {
		body_sx = 22.5;
		body_sy = 23.2;
		cuboid([body_sx, body_sy, 12], anchor=FRONT); // Body
		T(-body_sx/2, body_sy-5) cuboid([3, 1.5, 4], anchor=RIGHT+BACK); // Wires
	}

	// Flaps
	T_servomotor_flap_front() {
		flaps_sy = 2.4;
		cuboid([32, flaps_sy, 12], anchor=FRONT); // Flaps
		rm() T(y=-eps) xcopies(28, 2) ycyl(h=flaps_sy+2*eps, r=1, anchor=FRONT); // Holes
	}
}

module T_servo_attach_down() T(z=-0.6) children();
module servo_attach() {
	$fn=21*5;
	tube(od=6.9, id=4, h=0.6, $fn=21*5, anchor=TOP); // Down ring
	T(z=-0.05) tube(od=6.9, id=5.4, h=2.3, $fn=21*5, anchor=BOTTOM); // Up ring

	zrot_copies(n=21) T(y=2.97, z=1.1, rx=90)
		prismoid(size1=[1.6, 2.3], size2=[0, 2.3], h=0.7); // Teeth
}


/** AS5600 **/

module T_as5600_board_holes() zrot_copies(n=4) T(xy=10-3.5/2) children();
module as5600_board() {
	board_sxy = 23;
	board_th = 1.6;

	holes_d = 3.5;
	holes_pos = 10 - holes_d/2;

	// PCB
	difference() {
		cuboid([board_sxy, board_sxy, board_th], rounding=2, except=[TOP, BOTTOM], anchor=TOP); // PCB
		T(z=eps) T_as5600_board_holes() zcyl(d=holes_d, h=board_th+2*eps, anchor=TOP); // Mounting holes
	}

	// Sensor
	sensor_sz = [5, 3, 1.5];
	cuboid(sensor_sz, anchor=BOTTOM);

	// Pins
	pins_i2c_sz = [10, 2.5, 10+board_th+2];
	pins_vcc_sz = [7.5, 2.5, 10+board_th+2];
	pins_d = board_sxy/2 - 5;
	T(y=pins_d, z=2) cuboid(pins_i2c_sz, anchor=TOP);
	T(y=-pins_d, z=2) cuboid(pins_vcc_sz, anchor=TOP);
}

function as5600_magnet_dim() = [5, 2];

module as5600_magnet() {
	dim = as5600_magnet_dim();
	zcyl(d=dim[0], h=dim[1], anchor=BOTTOM);
}


/** ESP controller **/

module esp_controller() tag_scope() diff() {
	cuboid([37, 22.5, 1], anchor=TOP); // PCB
	xflip_copy(9.5) cuboid([8, 2.5*8, 25], anchor=BOTTOM+LEFT); // Wires pins
	xflip_copy(6.5) cuboid([2, 2.5*8, 12], anchor=BOTTOM+LEFT); // ESP module connectors
	T(z=12.5) {
		pcb_sy = 22.5;
		cuboid([17.5, pcb_sy, 0.5], anchor=TOP); // ESP::board
		T(y=pcb_sy/2+1) cuboid([8.5, 7, 3], anchor=BOTTOM+BACK, rounding=1.5, edges="Y"); // ESP::USB
	}
	rm() xflip_copy(5) T(y=-9, z=eps) zcyl(h=1+2*eps, d=2, anchor=TOP); // Holes
}


/** Tire **/

function tire_dim() = [40, 35.2];

module tire() {
	tdim = tire_dim();
	torus(od=tdim[0], id=tdim[1]);
}


/** Washers **/

function washer_M8_A_dim() = [8.4, 17, 1.6];
module washer_M8_A() {
	dim = washer_M8_A_dim();
	tube(id=dim[0], od=dim[1], h=dim[2]);
}

function washer_M6_A_dim() = [6.4, 12.5, 1.6];
module washer_M6_A() {
	dim = washer_M6_A_dim();
	tube(id=dim[0], od=dim[1], h=dim[2]);
}


/** Battery **/

module battery_holder(with_battery = true) {
	difference() {
		cuboid([76, 21, 19], rounding=5, edges=[TOP+BACK, TOP+FRONT], anchor=BOTTOM); // Body
		T(z=1+eps) cuboid([76-1.6*2, 21-1.2*2, 19-1], anchor=BOTTOM); // Main pocket
		zcyl(d=3, h=2); // Bottom hole
		xflip_copy(35) cuboid([3,8,3]); // Bottom rectangular holes
		xflip_copy(37) T(y=5, z=3) cuboid([3,8,3]); // Side rectangular holes
	}
	if (with_battery) T(z=2) xcyl(h=65, d=18, anchor=BOTTOM); // Battery
}

module battery_charger() {
	difference() {
		cuboid([25, 20.5, 1.5]); // PCB
		ycopies(20, 2) zcyl(d=2.5, h=3); // PCB holes
	}
	T(x=6.5, z=0.75, rz=90) cuboid([8.5, 7, 3], anchor=BOTTOM+BACK, rounding=1.5, edges="Y"); // USB
}


/** VL53L3CX **/

module vl53l3cx() {
	cuboid([15.8, 12.6, 1.5]); // PCB
	T(y=-2, z=1.5) cuboid([4.5, 2.5, 1.5]); // Sensor
	T(y=4.3, z=-1.5/2) cuboid([15, 2.5, 15], anchor=TOP); // Wires
	xflip_copy(10.4) difference() { // Ears
		cuboid([5.2, 5.2, 1.5], rounding=2.5, edges=[RIGHT+BACK, RIGHT+FRONT]);
		T(x=-0.4) zcyl(h=1.5+eps, d=3.2);
	}
}
