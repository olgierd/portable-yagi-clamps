include <threads.scad>

$fn=80;

holder(
    dia=22.3,           // boom diameter 
    thi=2,              // wall thickness
    rise=7,             // rise element above the boom
    h=10,               // clamp height (thickness)
    thr_len=5,          // thread length
    el_hole=3.7,        // element hole diameter
    gap=4,              // width of bottom gap for screw
    scr_prot=6,         // screw protrusion
    scr_dia=3.2,        // screw hole diameter (3.2 mm for M3)
    scr_head_dia=6,     // diameter of screw head (6mm for M3)
    scr_nut_dia=6.6,    // diameter of screw nut (6.6 for M3)
    sma_thi=5,          // thickness of SMA mount
    sma_hole_dia=3,     // SMA flange hole diameter
    sma_hole_dist=6.13, // distance from SMA hole center to socket center
    sma_nut_wid=5.1,    // width of the hole for SMA nut
    sma_socket_pos=16.5 // SMA socket offset relative to boom center
);

module holder(dia, thi, h, thr_len, el_hole, gap, scr_prot, scr_dia, scr_head_dia, scr_nut_dia, rise, sma_thi, sma_hole_dia, sma_hole_dist, sma_nut_wid, sma_socket_pos) {
    
    clamp(d_in=dia, thi=thi, h=h, gap=gap, scr_prot = scr_prot, scr_dia = scr_dia, scr_head_dia = scr_head_dia, el_hole = el_hole, scr_nut_dia=scr_nut_dia, rise=rise, sma_thi=sma_thi, sma_hole_dia=sma_hole_dia, sma_hole_dist=sma_hole_dist, sma_nut_wid=sma_nut_wid, sma_socket_pos=sma_socket_pos);
    
    translate([0,dia/2+thi+0.49+rise,0])
    element_thread(d_in = dia, h=h, thr_len = thr_len, el_hole = el_hole, sma_hole_dist=sma_hole_dist);
}


module clamp(d_in, thi, h, gap, scr_prot, scr_dia, scr_head_dia, el_hole, scr_nut_dia, rise, sma_thi, sma_hole_dia, sma_hole_dist, sma_nut_wid, sma_socket_pos) {
    difference() {
        
        // main shape
        union() {
            hull() {
                // top part
                cylinder(h=h, d=d_in+thi*2, center=true);
                translate([0,d_in/2+thi+rise,0])
                cube([d_in+thi*2,1,h], center=true);
                
                // screw protrusion
                translate([0,-d_in/2-thi-scr_prot,0])
                cube([gap+thi*2,0.1,h], center=true);
            }
            
            // SMA socket mount
            translate([0,0,(h+sma_thi)/2])
            intersection() {
                hull() {
                    // top part
                    cylinder(h=sma_thi, d=d_in+thi*2, center=true);
                    translate([0,d_in/2+thi+rise,0])
                    cube([d_in+thi*2,1,sma_thi], center=true);                    
                }
                translate([0,d_in/2+rise/2+1,0])
                cube([d_in+2*thi,thi+rise+1,(h+sma_thi)*2], center=true);
            }
        }

        // boom hole
        cylinder(h=h*3, d=d_in, center=true);
        
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
        translate([0, d_in/2+thi+0.5+rise,0])
        rotate([0,90,0])
        cylinder(h=d_in*2, d=el_hole, center=true);
        
        // SMA nut hole (right one, with strip hole
        translate([sma_hole_dist,d_in/2,h/2])
        union(){ 
            cube([sma_nut_wid,d_in/2+rise-2,2.6], center=true);
            translate([0,(d_in/2+rise-2)/2,2.6/2-1/2])
            cube([5,5,1], center=true);
        }
        
        // left SMA nut hole
        translate([-sma_hole_dist,d_in/2,h/2])
        cube([sma_nut_wid,d_in/2+rise-2,2.6], center=true);
        
        // SMA screw holes
        for(x=[-1,1])
        translate([x*sma_hole_dist,sma_socket_pos,sma_thi])
        cylinder(d=3,h=10.01, center=true);
        
        // SMA center pin hole
        translate([0,sma_socket_pos,sma_thi])
        cylinder(d=4.5,h=10.01, center=true);
        
        // SMA central pin to dipole-element hole
        %translate([-2,sma_socket_pos,1])
        rotate([270,0,0])
        cylinder(d=3,h=(d_in/2+rise+1)-sma_socket_pos+1);
        

    }
    
    // SMA - support for mounting screws nut holes 
    for(x=[-1,1])
    translate([x*sma_hole_dist,sma_socket_pos,6.4])
    cube([5,5,0.2], center=true);

    // dipole elements separator
    translate([0,d_in/2+rise+thi/2+0.575,0])
    cube([0.8,el_hole/2,el_hole], center=true);
}

module element_thread(d_in, h, thr_len, el_hole, sma_hole_dist) {
    difference() {
        // flattened thread
        intersection(){ 
            rotate([-90,0,0])
            metric_thread(16, 2, thr_len, internal=false);
            cube([d_in, thr_len*2, h], center=true);
        }
        
        // main hole
        translate([0, el_hole/2, 0])
        translate([0,-el_hole/2,0])
        rotate([0,90,0])
        cylinder(h=d_in*2, d=el_hole, center=true, $fn=20);
        
        // alignment hole
        translate([0,el_hole/3,0])
        rotate([-90,0,0])
        cylinder(d1=el_hole, d2=el_hole*2.5, h=thr_len);

        // dipole ground leg stripe connection
        translate([sma_hole_dist,0.2,0])
        union(){ 
            cube([5,0.4,h+0.1], center=true);
        }
    
    }
}