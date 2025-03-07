include <BOSL2/std.scad>
include <BOSL2/screws.scad>
include <BOSL2/gears.scad>
include <BOSL2/joiners.scad>

$fa = $preview ? 5 : 1;
$fs = $preview ? 1 : 0.1;
eps = 0.01;

module keep() {
	tag("keep") children();
}

module rm() {
	tag("remove") children();
}

module switch(n) {
	if (n < $children)
		children(n);
}

module axes(s=10) {
	recolor("#cccccc") keep() scale(s/10) spheroid(d=3) {
		yrot(90) attach(CENTER, BOT) recolor("#ff0000") cyl(h=10, d=1) {
			attach(TOP, BOT) cyl(h=5, d1=3, d2=0);
		}
		xrot(-90) attach(CENTER, BOT) recolor("#00ff00") cyl(h=10, d=1) {
			attach(TOP, BOT) cyl(h=5, d1=3, d2=0);
		}
		attach(CENTER, BOT) recolor("#0000ff") cyl(h=10, d=1) {
			attach(TOP, BOT) cyl(h=5, d1=3, d2=0);
		}
	}
}

module T(
	x=0, y=0, z=0, xy=0, yz=0, xz=0,
	rx=0, ry=0, rz=0,
	tx=0, ty=0, tz=0, txy=0, tyz=0, txz=0
) {
	module t(x, y, z) {
		if (x != 0 || y != 0 || z != 0)
			translate([x, y, z]) children();
		else
			children();
	}

	module r(x, y, z) {
		if (x != 0 || y != 0 || z != 0)
			rotate([x, y, z]) children();
		else
			children();
	}

	t(x+xy+xz, y+xy+yz, z+xz+yz)
		r(rx, ry, rz)
			t(tx+txy+txz, ty+txy+tyz, tz+txz+tyz)
				children();
}
