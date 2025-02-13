include <BOSL2/std.scad>
include <BOSL2/joiners.scad>

$fa = $preview ? 5 : 1;
$fs = $preview ? 1 : 0.1;

mode = 0; // [0: Assembly, 1: Pillar, 2: Pillar finish, 3: Platform 2D cut]

/* [Assembly parameters] */
show_pillar = true;
show_platform = true;
simplified = true;
grid_n = 1;

module pdtail(genre_bool=true) {
    genre = genre_bool ? "male" : "female";
    o = genre_bool ? 0 : 0.2;
    rot([90, 0, 90]) dovetail(genre, slide=3, chamfer=1, width=9+o, height=7+o, anchor=BOTTOM+FRONT);
}

module platform_shape() {
    c = 190;
    difference() {
        square(c, center=true);
        zrot_copies(n=4) move([c/2, c/2]) {
            circle(d=30);
            projection() zrot(-45) fwd(14) zrot(90) pdtail(false);
        }
    }
}

module platform() {
    color("#ffcc0080")
        linear_extrude(3)
            platform_shape();    
}

module pillar_base_shape() {
    round2d(r=2) {
        zrot_copies(n=4, sa=45) {
            fwd(14) scale([1.4, 1.2]) projection() zrot(-90) pdtail();
            circle(d=33);
        }
    }
}

module pillar_base() {
    s = 120 / (120 - 2 * 2);
    linear_extrude(2, scale=s)
        scale(1/s) pillar_base_shape();
    up(2) linear_extrude(1) pillar_base_shape();
}

module pillar_pin(h=30, l=10, e=2, simplified=false) {
    gap = 3.1;
    if (simplified) {
        zrot_copies(n=4) cuboid(
            [gap+l, gap+2*e, h],
            anchor=BOTTOM+LEFT);
    } else {
        zrot_copies(n=4) yflip_copy() {
            move([gap/2, -gap/2]) {
                hull() {
                    up(h-0.5) fwd(e/2) cuboid(
                        [l*.7, e, 3*e],
                        rounding=e/2,
                        anchor=TOP+LEFT
                    );
                    up(0.7*h) fwd(1.3*e/2) cuboid(
                        [l, 1.3*e, 0.01],
                        rounding=e/2,
                        except=[TOP, BOTTOM],
                        anchor=BOTTOM+LEFT
                    );
                    fwd(e) cuboid(
                        [l, 2*e, 0.01],
                        rounding=e/2,
                        except=[TOP, BOTTOM],
                        anchor=BOTTOM+LEFT
                    );
                }
            }
            move([gap/2+e/2, gap/2+e+e, 0]) rot([90, 0, 90])
                rounding_edge_mask(
                    h=l-e,
                    r1=l-2*e,
                    r2=0,
                    ang=180-atan2(h, e*1.05),
                    anchor=BOTTOM
                );
        }
        cuboid(
            [gap+2*e, gap+2*e, h],
            rounding=1,
            edges=TOP,
            anchor=BOTTOM);
    }
}

module pillar_noholes(simplified=false, finish=false) {
    down(3) pillar_base();
    zcyl(h=3, d=30.2, chamfer2=0.5, anchor=BOTTOM);
    if (!finish) up(3) pillar_pin(simplified=simplified);
    zrot_copies(n=4, sa=45) fwd(14) zrot(-90) pdtail();
}

module pillar(simplified=false, finish=false) {
    if (simplified) pillar_noholes(true, finish);
    else difference() {
        pillar_noholes(false, finish);
        down(4) {
            zrot_copies(n=4, sa=45) xcyl(h=30, d=6, spin=45, anchor=LEFT);
            if (!finish) zcyl(h=39, d1=7, d2=4, anchor=BOTTOM);
            if (!finish) zcyl(h=7, d1=20, d2=6, anchor=BOTTOM);
            if (finish) zcyl(h=5, d1=20, d2=2, anchor=BOTTOM);
        }
        if (!finish) up(5+30-2) rounding_hole_mask(d=4, rounding=0.5);
        up(2.5) zrot_copies(n=4) zrot(45) fwd(14.5) linear_extrude(1) left(2.8) round2d(r=0.2) scale(0.3) import("diode.svg");
        if (finish) up(2.5) linear_extrude(1) left(7.6) back(3.6) round2d(r=0.2) scale(0.8) import("diode.svg");
    }
}

if (mode == 1) { // Pillar
    pillar(false, false);
} else if (mode == 2) { // Pillar finish
    pillar(false, true);
} else if (mode == 3) { // Platform 2D cut
    platform_shape();
} else { // Assembly
    if (show_pillar) grid_copies(spacing=190, n=grid_n+1) pillar(simplified);
    if (show_platform) grid_copies(spacing=190, n=grid_n) platform();
}