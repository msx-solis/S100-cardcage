// This is the top side with card guides.
// Orientation:
// x = 0 : left edge of backplane PCB
// y = 0 : top of backplane
// z = 0 : outermost surface of card guide

include <s100_defs18-2c.scad>

$fn = 40;

bar_length = mod_width + 2*(cg_slot_gap+cg_depth);
echo(bar_length);

//cube([10,10,10])

difference(){
  // Additions (guides, frame, lip, etc)
  union(){
    translate([0, -bar_height/2, 0]) cube(size=[bar_length,bar_height,bar_width-2], center=false);
      }
  // Through holes
  translate([cg_depth/2, 0, -1]) cylinder(h=bar_width+2, d=screw_clearance, center=false); 
  translate([bar_length-cg_depth/2, 0, -1]) cylinder(h=bar_width+2, d=screw_clearance, center=false); 
  //picos quitados  
  translate ([0,8,0]) rotate([0,0,45]) cube([10,10,20], center=true);
  translate ([0,-8,0]) rotate([0,0,45]) cube([10,10,20], center=true);
  translate ([275,8,0]) rotate([0,0,45]) cube([10,10,20], center=true);
  translate ([275,-8,0]) rotate([0,0,45]) cube([10,10,20], center=true);

  // Shallow counterbores
  translate([cg_depth/2, 0, bar_width-screw_head_depth-.5]) cylinder(h=screw_head_depth+1, d=screw_head_dia, center=false); 
  translate([bar_length-cg_depth/2, 0, bar_width-screw_head_depth-.5]) cylinder(h=screw_head_depth+1, d=screw_head_dia, center=false); 
}

