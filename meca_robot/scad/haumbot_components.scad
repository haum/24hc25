include <haumbot_tools.scad>
use <haumbot_extparts.scad>

display = 0; // [0: washer_clip M8, 1: washer_clip_cap M8, 2: washer_clip M6, 3: washer_clip_cap M6]
switch(display) {
	washer_clip(washer_M8_A_dim());
	washer_clip_cap(washer_M8_A_dim());
	washer_clip(washer_M6_A_dim());
	washer_clip_cap(washer_M6_A_dim());
}

module washer_clip_cap(wdim, hole=false) {
	w = wdim[1]+4;
	od = wdim[1];
	wh = wdim[2];
	h = wh+1;
	l = 9;
	o1 = hole ? 1.3 : 0;
	o0 = hole ? 0.3 : 0;
	difference() {
		T(x=4) {
			T(x=-2.5) cuboid([w/2-2.5, w+2, h], rounding=2, except=[TOP, BOTTOM], anchor=LEFT); // Top
			yflip_copy() T(y=w/2) { // Legs
				T(y=1+o1) cuboid([l+o0, 1+o1, h+o1], anchor=RIGHT+BACK);
				T(x=-l+1.5-o0/2, y=-1, rx=-90) prismoid(size1=[1+o0,2+o1], size2=[2+o0,2+o1], shift=[-0.5,0], h=1);
			}
		}
		T(x=4) cuboid([4, w, h+eps], rounding=2, except=[TOP, BOTTOM], anchor=RIGHT); // Cut top
		zcyl(d1=od-0.05, d2=od+0.15, h=wh+0.1); // Washer cut
		zcyl(d=wdim[0]+1, h=h+0.1); // Additional hole for axis
	}
}

module washer_clip(wdim) tag_scope() diff() {
	id = wdim[0];
	od = wdim[1];
	wh = wdim[2];
	h = wh+1;
	a = 70;
	od2 = od + 4;
	hole_d = od-3;

	T(z=-h/2) {
		zcyl(h=h, d=od2, anchor=BOTTOM); // Outer cylinder
		rm() T(z=-eps) zcyl(d=hole_d, h=h+2*eps, anchor=BOTTOM); // Inner hole
		rm() T(z=-eps) pie_slice(ang=2*a, d=od2*1.1, h=h+2*eps, spin=-a); // Pie cut
		rm() T(z=h+eps+-0.5) zcyl(d1=od-0.05, d2=od+0.15, h=wh+0.1, chamfer2=0, anchor=TOP); // Washer hole
	}

	cuboid([7, od2+8, h], rounding=2, except=[TOP, BOTTOM], anchor=RIGHT); // Ears
	rm() washer_clip_cap(wdim, true); // Clip holes in ears
}

module plate(h=2, h0=1) {
	linear_extrude(h0) children(0);
	T(z=h0) linear_extrude(h) difference() {
		children(0);
		offset(-1) children(0);
	}
}
