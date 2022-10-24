// This is the top side with card guides.
// Orientation:
// x = 0 : left edge of backplane PCB
// y = 0 : top of backplane
// z = 0 : outermost surface of card guide

include <s100_defs18-2c.scad>

$fn = 40;

lip_to_mod = (bp_hole_row3 - bp_hole_row2)/2 + bp_hole_row2 + mod_width/2 - mod_ofs - bp_height - edge[3];
lip_z = lip_to_mod + cg_slot_gap + cg_depth;
screw_cb = lip_z - attach_thick;


difference(){
  // Additions (guides, frame, lip, etc)
  union(){
    base_lip(lip_z, 0); //base (ancho, si no 0, mal)
    card_guides(0); //guias para la tarjeta
    add_frame(lip_z, 0); //estructura de soporte para las guias
    
    translate ([0,93.2,0]) cube([200,10,3]); //arriba soporte fan
    translate ([0,21.2,0]) cube([200,10,3]); //abajo soporte fan
 }
    
  // Removals (holes + slot cutouts)
  //translate ([0,+1.5,0]) mtg_holes(0); //agujeros de union al centro, cero o no.
  card_slots(0); //hueco para la tarjeta
  attach_holes(0); //agujeros para la barra sup
  attach_cutout(0); //cuadrados para barra sup
  support_holes(screw_threads, 1); //tornillo al frontal
  top_chamfer(0); //chaflan superior
  //cutout delantero
  translate([-34.04,-30,-10]) cube(size=[98.27,180,50]);  //0.5 recortado de -53.1
  //cutout trasero
  translate([102.3,-30,-10]) cube(size=[98,180,50]); //101.8 o 102.3
  rotate([90,0,0]) translate ([-20,-20,+8]) cube([190.5+40, 216+40, 9]); 
  translate ([70,-4.8,6]) rotate([0,0,90]) cylinder(h=15, d=3.4, center=false);
  translate ([98,-4.8,6]) rotate([0,0,90]) cylinder(h=15, d=3.4, center=false); 
 
  translate ([74,26,-2]) rotate([0,0,90]) cylinder(h=15, d=4.4, center=false);
  translate ([74,26+72,-2]) rotate([0,0,90]) cylinder(h=15, d=4.4, center=false);
  translate ([74-4.2,26,-2]) rotate([0,0,90]) cylinder(h=15, d=4.4, center=false);
  translate ([74-4.2,26+72,-2]) rotate([0,0,90]) cylinder(h=15, d=4.4, center=false);

  translate ([74+19.05,26,-2]) rotate([0,0,90]) cylinder(h=15, d=4.4, center=false);
  translate ([74+19.05,26+72,-2]) rotate([0,0,90]) cylinder(h=15, d=4.4, center=false);
  translate ([74-4.2+19.05,26,-2]) rotate([0,0,90]) cylinder(h=15, d=4.4, center=false);
  translate ([74-4.2+19.05,26+72,-2]) rotate([0,0,90]) cylinder(h=15, d=4.4, center=false);

 }
