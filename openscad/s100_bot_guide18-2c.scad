// This is the top side with card guides.
// Orientation:
// x = 0 : left edge of backplane PCB
// y = 0 : top of backplane
// z = 0 : outermost surface of card guide

include <s100_defs18-2c.scad>

$fn = 40;

lip_to_mod = mod_width/2 + mod_ofs - ((bp_hole_row3 - bp_hole_row2)/2 + bp_hole_row2) - edge[3];
lip_z = lip_to_mod + cg_slot_gap + cg_depth;
screw_cb = lip_z - attach_thick;

echo(lip_to_mod);


difference(){
  // Additions (guides, frame, lip, etc)
  union(){
    base_lip(lip_z, 1);
    card_guides(1);
    add_frame(lip_z, 1);
    translate ([0,-103.2,0]) cube([200,10,3]);
    translate ([0,-31.2,0]) cube([200,10,3]);
  }
  
  // Removals (holes + slot cutouts) //19.05
  //translate ([0,-1.5,0]) mtg_holes(1);
  card_slots(1);
  attach_holes(1); 
  attach_cutout(1);
  support_holes(screw_threads, -1);
  top_chamfer(1);
  //cutout delantero
  translate([-34.04,-150,-10]) cube(size=[98.27,280,50]); //0.5 recortado de -53.1
  //cutout trasero
  translate([102.3,-150,-10]) cube(size=[118,280,50]);  //101.8 o 102.3
  translate ([-20,+16,-10]) rotate([90,0,0]) cube([190.5+40, 216+40, 9-1]); 
  //#cube([190.5+20, 216+20, 9-6]);  
  translate ([70,4.8,16]) rotate([0,0,90]) cylinder(h=15, d=3.4, center=false);
  translate ([98,4.8,16]) rotate([0,0,90]) cylinder(h=15, d=3.4, center=false);

  translate ([74,-26,-2]) rotate([0,0,90]) cylinder(h=15, d=4.4, center=false);
  translate ([74,-26-72,-2]) rotate([0,0,90]) cylinder(h=15, d=4.4, center=false);
  translate ([74-4.2,-26,-2]) rotate([0,0,90]) cylinder(h=15, d=4.4, center=false);
  translate ([74-4.2,-26-72,-2]) rotate([0,0,90]) cylinder(h=15, d=4.4, center=false);

  translate ([74+19.05,-26,-2]) rotate([0,0,90]) cylinder(h=15, d=4.4, center=false);
  translate ([74+19.05,-26-72,-2]) rotate([0,0,90]) cylinder(h=15, d=4.4, center=false);
  translate ([74-4.2+19.05,-26,-2]) rotate([0,0,90]) cylinder(h=15, d=4.4, center=false);
  translate ([74-4.2+19.05,-26-72,-2]) rotate([0,0,90]) cylinder(h=15, d=4.4, center=false);
  }
