include <threads.scad>  // get from https://dkprojects.net/openscad-threads/

$fn=80;

holder(
    dia=22.3,           // boom diameter 
    thi=2,              // wall thickness
    h=10,               // clamp height (thickness)
    thr_len=5,          // thread length
    el_hole=3.7,        // element hole diameter
    gap=4,              // width of bottom gap for screw
    scr_prot=6,         // screw protrusion
    scr_dia=3.2,        // screw hole diameter (3.2 mm for M3)
    scr_head_dia=6,     // diameter of screw head (6 mm for M3)
    scr_nut_dia=6.6     // diameter of screw nut (6.6 mm for M3)
);

//translate([0,35,0])
//nut(d_ext=22, h=4, thr_dia=16.5);


module holder(dia, thi, h, thr_len, el_hole, gap, scr_prot, scr_dia, scr_head_dia, scr_nut_dia) {
    
    clamp(d_in=dia, thi=thi, h=h, gap=gap, scr_prot = scr_prot, scr_dia = scr_dia, scr_head_dia = scr_head_dia, el_hole = el_hole, scr_nut_dia=scr_nut_dia);
    
    translate([0,dia/2+thi+0.49,0])
    element_thread(d_in = dia, h=h, thr_len = thr_len, el_hole = el_hole);
}


module clamp(d_in, thi, h, gap, scr_prot, scr_dia, scr_head_dia, el_hole, scr_nut_dia) {
    difference() {
        
        // main shape
        hull() {
            // top part
            cylinder(h=h, d=d_in+thi*2, center=true);
            translate([0,d_in/2+thi,0])
            cube([d_in+thi*2,1,h], center=true);
            
            // mounting screw protrusion
            translate([0,-d_in/2-thi-scr_prot,0])
            cube([gap+thi*2,0.1,h], center=true);
        }

        // boom hole
        cylinder(h=h+1, d=d_in, center=true);
        
        // clamp gap
        translate([0,-d_in/2,0])
        cube([gap,d_in,h+1], center=true);
        
        // screw hole
        translate([0,-d_in/2-(scr_prot+thi)/2,0])
        rotate([0,90,0])
        cylinder(d=scr_dia, h=d_in, center=true);
        
        // screw head
        translate([gap/2+thi,-d_in/2-(scr_prot+thi)/2,0])
        rotate([0,90,0])
        cylinder(d=scr_head_dia, h=d_in);
        
        // screw nut
        translate([-gap/2-thi,-d_in/2-(scr_prot+thi)/2,0])
        rotate([0,-90,0])
        cylinder(d=scr_nut_dia, h=d_in, $fn=6);
        
        // element undercut
        translate([0, d_in/2+thi+0.5,0])
        rotate([0,90,0])
        cylinder(h=d_in*2, d=el_hole, center=true);
    }
}

module element_thread(d_in, h, thr_len, el_hole) {
    difference() {
        // flattened thread
        intersection(){ 
            rotate([-90,0,0])
            metric_thread(16, 2, thr_len, internal=false);
            cube([d_in, thr_len*2, h], center=true);
        }
        
        // element hole
        translate([0, el_hole/2, 0])
        translate([0,-el_hole/2,0])
        rotate([0,90,0])
        cylinder(h=d_in*2, d=el_hole, center=true, $fn=20);
        
        // alignment hole
        translate([0,el_hole/3,0])
        rotate([-90,0,0])
        cylinder(d1=el_hole, d2=el_hole*2.5, h=thr_len);

    }
}

module nut(d_ext, h, thr_dia) {
    difference() {
        cylinder(d=d_ext, h=h-0.02, $fn=6);
        translate([0,0,-0.01])
        metric_thread(thr_dia, 2, h, internal=true);
    }
}