// 9-Slot backplane definitions
// Orientation is slots vertical, slot 1 on left, same as drawing in user manual.
// Origin is PCB lower left corner at 0,0,0. (bottom PCB at Z = 0)
// units are in mm
// I exported the KiCad file to a STEP file, imported into Fusion 360, and measured features.

bp_width  = 190.5;
bp_height = 216;
bp_thick  = 2.40;

// Slot horizontal offsets
bp_s1_ofs     = 16.25;      // Left edge to slot 1
bp_s1_s2_ofs  = 26.42;      // slot 1 to slot 2 (1.040 inches)
bp_slot_ofs   = 19.05;      // remaining slot to slot offset (0.75 inches)
bp_slots      = 9;

// Hole vertical offsets, bottom to top
bp_hole_row1  = 15.9;
bp_hole_row2  = 24.7;
bp_hole_row3  = 197.3;
bp_hole_row4  = 206.4;

// Leftmost mounting hole distance from left PCB edge.
mtg_hole1     = 4.572;

// Note that the top mounting hole above slot 1 is (mistakenly?) off grid. It is low and left.
// These are the corrections for that one hole.
mtg_s1_dx     = -0.37;      // Slot 1 upper mounting hole X placement error
mtg_s1_dy     = -0.38;      // Slot 1 upper mounting hole Y placement error
err_hole_y    = bp_hole_row4 + mtg_s1_dy;

// 6-32 screw constants
screw_head_depth  = 3.5;     // counter-bore depth when using a socket head cap screw
screw_head_dia    = 6.0;    // counter-bore dia when using a socket head cap screw
screw_clearance   = 3.7;    // through hole diameter
screw_threads     = 3.35;   // 2.8 for tapped holes, 3.35 for self threading

base_thick = 9;
boss_thick = 3.5;
boss_dia   = 6.5;
attach_thick = 6;           // Material between mounting surface and screw counterbore

// Baseplate edge (lip beyond backplane)
edge = [4, 4, 4, 4];        // left, right, top, bottom

// Baseplate cutout features. For now centered, should add offsets.
cutout_x = 190;
cutout_y = 160;
web = 10;

// Module related
mod_width     = 254;        // 10.0" Nominal card width
mod_height    = 127;        //  5.0" Nominal height minus card fingers
mod_conn      = 15.2;       //  0.6" Height from top of backplane to module bottom (above fingers)
mod_ofs       = 8;          // fingers are offset from center this much toward bottom

// Card guide related
cg_slot_width = 1.9;
cg_slot_depth = 2.5;        // 0.1" The amount overlapping the module edge
cg_slot_gap   = 0.5;        // The extra on each side from the nominal board width of 10.000 inches
cg_width      = 5;          // width of the card guide
cg_depth      = 10;         // Card guide thickness. Module edge to cage outer dimension.
cg_bev_width  = 4;
cg_bev_height = 3;
cg_chamfer    = 1.5;          // top inside edge chamfer on card guide rail.
cg_slot_ofs   = 8;          // How far down from top edge do card lips start. (need to clear ejector)

// Bar that spans the outer card guides
bar_width 		= 6;
bar_height 		= 10;

// Below the actual card guide area, we extend down to the lip with this size v strut.
// The lower cross bar is h strut in height.
lower_vstruts = cg_width;
lower_hstrut  = 6;

// Calculate the slot offsets from the left edge for each slot and turn into a vector.
// If i == 0, use the initial offset.
// If i == 1, use the initial offset plus slot 1-2 offset
// For all others, use the initial offset plus slot 1-2 offset plus slot*0.75
function slot_offsets(x0, x1, xn, n) = [
  for(i = [0:n-1])
    i < 1 ? x0 : i < 2 ? x0 + x1 : x0 + x1 + ((i-1) * xn)];

// slot_ofs  : x distance from left PCB edge to each slot
// t_b_holes : x distance from left PCB edge to the top/bottom card guide mounting holes
slot_ofs  = slot_offsets(bp_s1_ofs, bp_s1_s2_ofs, bp_slot_ofs, bp_slots);
t_b_holes = [slot_ofs[0] + bp_slot_ofs/2, slot_ofs[2] + bp_slot_ofs/2, slot_ofs[4] + bp_slot_ofs/2, slot_ofs[7] + bp_slot_ofs/2];

lip_y = base_thick+boss_thick+bp_thick;
hole_dy = lip_y - base_thick/2;   // move up from the bottom of the lip base_thick/2 - same as baseplate
base_width = bp_width+edge[0]+edge[1];
top_edge = mod_conn + mod_height;


// +rotation = CCW, -rotation = CW
module triangle(x, y, z, rot, size, ht){
		translate([x, y, z]) 
			rotate(a=rot) 
		    difference(){
		        cube([size,size,ht], center=false);
		        translate([size, 0, -1]) rotate([0,0,45]) cube([size*2000,size*2000,size*2000], center=false);
		    }
}

module support_holes(dia, dir){
  ofs = dir*50;
  translate([-edge[0]-1, -dir*hole_dy, cg_depth/2]) rotate(a=[0, 90, 0]) cylinder(h=12, d=dia, center=false); 
  translate([-edge[0]-1, -dir*hole_dy+ofs, cg_depth/2]) rotate(a=[0, 90, 0]) cylinder(h=12, d=dia, center=false); 
  translate([-edge[0]-1, -dir*hole_dy+2*ofs, cg_depth/2]) rotate(a=[0, 90, 0]) cylinder(h=12, d=dia, center=false); 

  translate([bp_width+edge[1]+1, -dir*hole_dy, cg_depth/2]) rotate(a=[0, -90, 0]) cylinder(h=12, d=dia, center=false); 
  translate([bp_width+edge[1]+1, -dir*hole_dy+ofs, cg_depth/2]) rotate(a=[0, -90, 0]) cylinder(h=12, d=dia, center=false); 
  translate([bp_width+edge[1]+1, -dir*hole_dy+2*ofs, cg_depth/2]) rotate(a=[0, -90, 0]) cylinder(h=12, d=dia, center=false); 
}

module card_guides(rot){
  ofs = rot == 0 ? mod_conn : -mod_conn; 
  union() {
    for(i = [0:len(slot_ofs)-1]){
        translate([slot_ofs[i], ofs, 0]) rotate(a=180, v=[0,0,rot]) card_guide(cg_width, mod_height, cg_depth, cg_slot_width, cg_slot_depth+cg_slot_gap); 
    }
  }
}

module card_guide(x, y, z, sx, sz){
  adjust = cg_slot_ofs+cg_slot_gap+cg_slot_depth;
    union(){
      translate([ -x/2,  0, 0]) cube(size=[x,y,z], center=false);
      translate([ -x/2,  0, 0]) cube(size=[x,y-adjust,z+sz], center=false);
      triangle(x/2, y-adjust, z, [0,-90,0], cg_slot_gap+cg_slot_depth, (x-sx)/2);
      triangle(-sx/2, y-adjust, z, [0,-90,0], cg_slot_gap+cg_slot_depth, (x-sx)/2);
    }
}

module card_slots(rot){
  yofs = rot == 0 ? mod_conn-1 : -mod_conn+1; 
  
  for(i = [0:len(slot_ofs)-1]){
    xofs = rot == 0 ? slot_ofs[i]-cg_slot_width/2 : slot_ofs[i]+cg_slot_width/2;
    translate([xofs, yofs, cg_depth]) rotate(a=180, v=[0,0,rot]) cube(size=[cg_slot_width,mod_height+2,cg_slot_depth+cg_slot_gap+4], center=false);
  }
}

module mtg_holes(rot){
    yofs = rot == 0 ? -hole_dy : hole_dy; 

    for(i = [0:len(t_b_holes)-1]){
        translate([t_b_holes[i], yofs, -1]) cylinder(h=lip_z+2, d=screw_clearance, center=false); 
        translate([t_b_holes[i], yofs, -1]) cylinder(h=screw_cb+1, d=screw_head_dia, center=false); 
    }
}

//base_lip(30,0);
module base_lip (z, rot){
  dy = rot == 0 ? -lip_y : 0; 
  translate([-edge[0], dy, 0]) cube(size=[base_width,lip_y,z], center=false);
}//largo, ancho, alto

module add_frame(lz, rot){
  mirror([0,rot,0])
  union(){
    for(i = [0:len(slot_ofs)-1]){
        translate([slot_ofs[i]-lower_vstruts/2, 0, 0]) cube(size=[lower_vstruts,mod_conn,cg_depth], center=false); 
    }
    translate([-edge[0], 0, 0]) cube(size=[bar_width,mod_conn+mod_height,cg_depth], center=false);              // left edge
    translate([bp_width+edge[1]-bar_width, 0, 0]) cube(size=[bar_width,mod_conn+mod_height,cg_depth], center=false);  // right edge
    translate([0, mod_conn+mod_height-bar_height, 0]) cube(size=[bp_width,bar_height,cg_depth], center=false);  // top edge
    translate([0, mod_conn, 0]) cube(size=[bp_width,lower_hstrut,cg_depth], center=false);  // bot edge
    triangle(-edge[0]+bar_width, mod_conn+mod_height-bar_height, 0, [0,0,-90], bar_height+2, cg_depth); // top left
    triangle(bp_width+edge[1]-bar_width, mod_conn+mod_height-bar_height, 0, [0,0,180], bar_height+2, cg_depth); // top right
    triangle(bar_width-edge[0], 0, cg_depth, [0,-90,0], lz-cg_depth, bar_width);
    triangle(bp_width+edge[1], 0, cg_depth, [0,-90,0], lip_z-cg_depth, bar_width);
  }
}

module top_chamfer(rot){
  mirror([0, rot, 0])
    triangle(-edge[0]-1,top_edge+.01,cg_depth+.01, [90,180,90], cg_chamfer, base_width+2);  // top bar chamfer
}

//#attach_holes(1);
module attach_holes(rot){
  mirror([0, rot, 0]){
    translate([-edge[0]-1, top_edge-bar_height/2, cg_depth/2]) 
      rotate(a=[0, 90, 0]) 
        cylinder(h=200, d=screw_threads, center=false); 
  }
}

module attach_cutout(rot){
  mirror([0, rot, 0]){
    translate([-edge[0]-1, top_edge-bar_height, -1]) 
      cube(size=[bar_width+1,bar_height+1,cg_depth+2], center=false);  // left cut
    translate([bp_width+edge[1]-bar_width, top_edge-bar_height, -1]) 
      cube(size=[bar_width+1,bar_height+1,cg_depth+2], center=false);  // left cut
  }
}


$fn = 40;

lip_to_mod = mod_width/2 + mod_ofs - ((bp_hole_row3 - bp_hole_row2)/2 + bp_hole_row2) - edge[3];
lip_z = lip_to_mod + cg_slot_gap + cg_depth;
screw_cb = lip_z - attach_thick;

echo(lip_to_mod);

//ladoizq();
//translate ([19.05*2,0,0]) ladoizq();
//sueloder();
//translate ([19.05*2,0,0]) sueloder();
//sueloizq();
//translate ([19.05*2,0,0]) sueloizq();
//ladoder();
//translate ([19.05*2,0,0]) ladoder();

module ladoizq(){
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
  translate([-34.0,-150,-10]) cube(size=[98.27,280,50]); //0.5 recortado de -53.1
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
}
//$fn = 40;

// tm_holes  : x distance from left PCB edge to top mounting holes (minus error hole)
// bm_holes  : x distance from left PCB edge to bot mounting holes
// err_hole  : x distance from left PCB edge to top mounting hole that was placed wrong
// mid_holes : x distance from left PCB edge to the two holes between slots 4 & 5
tm_holes  = [mtg_hole1, slot_ofs[1], slot_ofs[3], slot_ofs[5], slot_ofs[7]];
bm_holes  = [mtg_hole1, slot_ofs[0], slot_ofs[1], slot_ofs[3], slot_ofs[5], slot_ofs[7]];
err_hole  = [slot_ofs[0] + mtg_s1_dx];
mid_holes = [slot_ofs[3] + ((slot_ofs[4]-slot_ofs[3])/2)];

//-------------------------------------------------------------------------------------------
// Main assembly
//-------------------------------------------------------------------------------------------
 //translate ([90,25,3]) cube([10,10,6]);//medidor
 module sueloder() {
 difference(){
  // Additions (baseplate + bosses) //19.05
  union(){
    baseplate(bp_width, bp_height, base_thick+1.5); //plataforma base
    //soporte tornillo imsai dcho
    //bosses(bm_holes,  boss_dia, bp_hole_row1, 0, base_thick+boss_thick);          // Bot mounting bosses
    //soporte tornillo altair dcho
    bosses(slot_ofs,  boss_dia, bp_hole_row2, 0, base_thick+boss_thick);          // Bot card connector bosses
    //soporte tornillo central dcho
    bosses(mid_holes, boss_dia, bp_hole_row2, 0, base_thick+boss_thick);          // Bot boss between slots 4 & 5
    //soporte tornillo central izq
    bosses(mid_holes, boss_dia, bp_hole_row3, 0, base_thick+boss_thick);          // Top boss between slots 4 & 5
    //soporte tornillo altair izq
    bosses(slot_ofs,  boss_dia, bp_hole_row3, 0, base_thick+boss_thick);          // Top card connector bosses
    //soporte tornillo imsai izq
    //bosses(tm_holes,  boss_dia, bp_hole_row4, 0, base_thick+boss_thick);          // Top mounting bosses (minus error)
    //soporte tornillo especial izq
    bosses(err_hole,  boss_dia, err_hole_y,   0, base_thick+boss_thick);          // Top mounting boss above slot 1
    //borde exterior de la base
    ledge(bp_width, bp_height, base_thick+boss_thick+bp_thick, edge);             // Ledge surrounding the backplane
      //agujeros derecha paso 3mm
    translate ([70,-3,10]) rotate([90,0,0]) cylinder(h=10, d=3.2, center=false);
    translate ([98,-3,10]) rotate([90,0,0]) cylinder(h=10, d=3.2, center=false);
   

  }
  
  // Removals (holes + cutouts)
  // agujeros imsai dcho
  bosses(bm_holes,  screw_threads, bp_hole_row1, -1, base_thick+boss_thick+2);      // Bot mounting holes
  // agujeros altair dcho
  bosses(slot_ofs,  screw_threads, bp_hole_row2, -1, base_thick+boss_thick+2);      // Bot card connector holes
  //agujero central dcho
  bosses(mid_holes, screw_threads, bp_hole_row2, -1, base_thick+boss_thick+2);      // Bot hole between slots 4 & 5
  //agujero central izdo
  bosses(mid_holes, screw_threads, bp_hole_row3, -1, base_thick+boss_thick+2);      // Top hole between slots 4 & 5
  //agujeros altair izdo
  bosses(slot_ofs,  screw_threads, bp_hole_row3, -1, base_thick+boss_thick+2);      // Top card connector holes
  //agujeros imsai izdo
  bosses(tm_holes,  screw_threads, bp_hole_row4, -1, base_thick+boss_thick+2);      // Top mounting holes (minus error)
  //agujero especial izdo
  bosses(err_hole,  screw_threads, err_hole_y,   -1, base_thick+boss_thick+2);      // Top mounting hole above slot 1
  //huecos centrales base
  do_cutout(bp_width+700, bp_height+7, cutout_x+1000, cutout_y+14, base_thick+2+4, web);            // Center cutouts in baseplate
  //agujeros derecha paso 3mm anulado
  //translate ([0,0,1.5]) edge_holes(t_b_holes,          -edge[3]-1, base_thick/2, -90, 75, screw_threads); // Bot card guide mounting holes
  //agujeros izquierda paso 3mm
  translate ([0,0,1.5]) edge_holes(t_b_holes, bp_height+edge[2]+1, base_thick/2,  90, 75, screw_threads); // Top card guide mounting holes
  //cutout delantero
  translate([-34,-30,-10]) cube(size=[98.27,280,50]);  //0.5 recortado de -53.1
  //cutout trasero
  translate([102.3,-30,-10]) cube(size=[98,280,50]);  //101.8 o 102.3
  //#translate ([0,145,1]) attach_holes(1); // agujero central
  translate ([-20,-20,-6]) cube([bp_width+40, bp_height+40, base_thick+4]); 
  //cutout lateral deja lado derecho
  translate([-33.25,+50,-10]) cube(size=[800,280,50]);  //0.5 recortado de -53.1
}
}  
//-------------------------------------------------------------------------------------------

// Mounting hole bosses (or holes). 
// You can choose to eliminate unused ones or keep for rigidity.
module bosses (ofs, dia, y, z, ht) {
  union() {
    for(i = [0:len(ofs)-1]){
        translate([ofs[i], y,  z]) cylinder(h=ht, d=dia, center=false); 
    }
  }
}

// Simple baseplate the size of the backplane.
module baseplate(x,y,z) {
  cube(size=[x,y,z], center=false);
}

// Add a ledge around the backplane. This ledge extends the base up to the top
// of the backplane so that the boss area is closed off from the outsides.
module ledge(x, y, z, vec){
  union(){
    translate([-vec[0], -vec[3], 0]) cube(size=[         vec[0], y+vec[2]+vec[3], z], center=false);   // left
    translate([-vec[0],       y, 0]) cube(size=[x+vec[0]+vec[1],          vec[2], z], center=false);   // top
    translate([      x, -vec[3], 0]) cube(size=[         vec[1], y+vec[2]+vec[3], z], center=false);   // right
    translate([-vec[0], -vec[3], 0]) cube(size=[x+vec[0]+vec[1],          vec[3], z], center=false);   // bottom
  }
}

// The cutout is used to save filament and time on the base. The backplane provides
// more than enough stiffness that a solid frame is not needed.
module do_cutout(x, y, cx, cy, ht, web){
    cutout(x/2-cx/4, y/2+cy/4, cx, cy, ht, web);
    cutout(x/2+cx/4, y/2+cy/4, cx, cy, ht, web);
    cutout(x/2-cx/4, y/2-cy/4, cx, cy, ht, web);
    cutout(x/2+cx/4, y/2-cy/4, cx, cy, ht, web);
}

module cutout(x, y, cx, cy, ht, web){
  hull(){
    translate([x-cx/4 + web, y+cy/4 - web, -1]) cylinder(h=ht, d=web, center=false);
    translate([x-cx/4 + web, y-cy/4 + web, -1]) cylinder(h=ht, d=web, center=false);
    translate([x+cx/4 - web, y+cy/4 - web, -1]) cylinder(h=ht, d=web, center=false);
    translate([x+cx/4 - web, y-cy/4 + web, -1]) cylinder(h=ht, d=web, center=false);
  }
}

// These are the holes that will be used to mount the 'ears' that have the card guides.
// The holes go into the top and bottom edges ofthe frame.
// ofs : vector of offsets from left PCB edge to each hole
// r   : cylinder rotation about X axis (-90 for bottom holes. +90 for top holes
module edge_holes(ofs, y, z, r, ht, dia){
  union() {
    for(i = [0:len(ofs)-1]){
        translate([ofs[i], y,  z]) rotate(r, [1, 0, 0]) cylinder(h=ht, d=dia, center=false); 
    }
  }
  
}

//$fn = 40;

// tm_holes  : x distance from left PCB edge to top mounting holes (minus error hole)
// bm_holes  : x distance from left PCB edge to bot mounting holes
// err_hole  : x distance from left PCB edge to top mounting hole that was placed wrong
// mid_holes : x distance from left PCB edge to the two holes between slots 4 & 5
//tm_holes  = [mtg_hole1, slot_ofs[1], slot_ofs[3], slot_ofs[5], slot_ofs[7]];
//bm_holes  = [mtg_hole1, slot_ofs[0], slot_ofs[1], slot_ofs[3], slot_ofs[5], slot_ofs[7]];
//err_hole  = [slot_ofs[0] + mtg_s1_dx];
//mid_holes = [slot_ofs[3] + ((slot_ofs[4]-slot_ofs[3])/2)];

//-------------------------------------------------------------------------------------------
// Main assembly
//-------------------------------------------------------------------------------------------
 //translate ([90,25,3]) cube([10,10,6]);//medidor
module sueloizq(){ 
difference(){
  // Additions (baseplate + bosses) //19.05
  union(){
    baseplate(bp_width, bp_height, base_thick+1.5); //plataforma base
    //soporte tornillo imsai dcho
    //bosses(bm_holes,  boss_dia, bp_hole_row1, 0, base_thick+boss_thick);          // Bot mounting bosses
    //soporte tornillo altair dcho
    bosses(slot_ofs,  boss_dia, bp_hole_row2, 0, base_thick+boss_thick);          // Bot card connector bosses
    //soporte tornillo central dcho
    bosses(mid_holes, boss_dia, bp_hole_row2, 0, base_thick+boss_thick);          // Bot boss between slots 4 & 5
    //soporte tornillo central izq
    bosses(mid_holes, boss_dia, bp_hole_row3, 0, base_thick+boss_thick);          // Top boss between slots 4 & 5
    //soporte tornillo altair izq
    bosses(slot_ofs,  boss_dia, bp_hole_row3, 0, base_thick+boss_thick);          // Top card connector bosses
    //soporte tornillo imsai izq
    //bosses(tm_holes,  boss_dia, bp_hole_row4, 0, base_thick+boss_thick);          // Top mounting bosses (minus error)
    //soporte tornillo especial izq
    bosses(err_hole,  boss_dia, err_hole_y,   0, base_thick+boss_thick);          // Top mounting boss above slot 1
    //borde exterior de la base
    ledge(bp_width, bp_height, base_thick+boss_thick+bp_thick, edge);             // Ledge surrounding the backplane
      //agujeros derecha paso 3mm
    translate ([70,229,10]) rotate([90,0,0]) cylinder(h=10, d=3.2, center=false);
    translate ([98,229,10]) rotate([90,0,0]) cylinder(h=10, d=3.2, center=false);

  }
  
  // Removals (holes + cutouts)
  // agujeros imsai dcho
  bosses(bm_holes,  screw_threads, bp_hole_row1, -1, base_thick+boss_thick+2);      // Bot mounting holes
  // agujeros altair dcho
  bosses(slot_ofs,  screw_threads, bp_hole_row2, -1, base_thick+boss_thick+2);      // Bot card connector holes
  //agujero central dcho
  bosses(mid_holes, screw_threads, bp_hole_row2, -1, base_thick+boss_thick+2);      // Bot hole between slots 4 & 5
  //agujero central izdo
  bosses(mid_holes, screw_threads, bp_hole_row3, -1, base_thick+boss_thick+2);      // Top hole between slots 4 & 5
  //agujeros altair izdo
  bosses(slot_ofs,  screw_threads, bp_hole_row3, -1, base_thick+boss_thick+2);      // Top card connector holes
  //agujeros imsai izdo
  bosses(tm_holes,  screw_threads, bp_hole_row4, -1, base_thick+boss_thick+2);      // Top mounting holes (minus error)
  //agujero especial izdo
  bosses(err_hole,  screw_threads, err_hole_y,   -1, base_thick+boss_thick+2);      // Top mounting hole above slot 1
  //huecos centrales base
  do_cutout(bp_width+700, bp_height+7, cutout_x+1000, cutout_y+14, base_thick+2+4, web);            // Center cutouts in baseplate
  //agujeros derecha paso 3mm anulado
  //translate ([0,0,1.5]) edge_holes(t_b_holes, -edge[3]-1, base_thick/2, -90, 75, screw_threads); // Bot card guide mounting holes
  //agujeros izquierda paso 3mm
  //translate ([0,10,1.5]) edge_holes(t_b_holes, bp_height+edge[2]+1, base_thick/2, 90, 75-40, screw_threads); // Top card guide mounting holes
  //cutout delantero
  translate([-34,-30,-10]) cube(size=[98.27,280,50]);  //0.5 recortado de -53.1
  //cutout trasero
  translate([102.3,-30,-10]) cube(size=[98,280,50]);  //101.8 o 102.3
  translate ([0,145,1]) attach_holes(1); // agujero central
  translate ([-20,-20,-6]) cube([bp_width+40, bp_height+40, base_thick+4]); 
  //cutout lateral deja lado derecho
  translate([-33.25,-150,-10]) cube(size=[800,280,50]);  //0.5 recortado de -53.1
}
}  
//-------------------------------------------------------------------------------------------

// Mounting hole bosses (or holes). 
// You can choose to eliminate unused ones or keep for rigidity.
module bosses (ofs, dia, y, z, ht) {
  union() {
    for(i = [0:len(ofs)-1]){
        translate([ofs[i], y,  z]) cylinder(h=ht, d=dia, center=false); 
    }
  }
}

// Simple baseplate the size of the backplane.
module baseplate(x,y,z) {
  cube(size=[x,y,z], center=false);
}

// Add a ledge around the backplane. This ledge extends the base up to the top
// of the backplane so that the boss area is closed off from the outsides.
module ledge(x, y, z, vec){
  union(){
    translate([-vec[0], -vec[3], 0]) cube(size=[         vec[0], y+vec[2]+vec[3], z], center=false);   // left
    translate([-vec[0],       y, 0]) cube(size=[x+vec[0]+vec[1],          vec[2], z], center=false);   // top
    translate([      x, -vec[3], 0]) cube(size=[         vec[1], y+vec[2]+vec[3], z], center=false);   // right
    translate([-vec[0], -vec[3], 0]) cube(size=[x+vec[0]+vec[1],          vec[3], z], center=false);   // bottom
  }
}

// The cutout is used to save filament and time on the base. The backplane provides
// more than enough stiffness that a solid frame is not needed.
module do_cutout(x, y, cx, cy, ht, web){
    cutout(x/2-cx/4, y/2+cy/4, cx, cy, ht, web);
    cutout(x/2+cx/4, y/2+cy/4, cx, cy, ht, web);
    cutout(x/2-cx/4, y/2-cy/4, cx, cy, ht, web);
    cutout(x/2+cx/4, y/2-cy/4, cx, cy, ht, web);
}

module cutout(x, y, cx, cy, ht, web){
  hull(){
    translate([x-cx/4 + web, y+cy/4 - web, -1]) cylinder(h=ht, d=web, center=false);
    translate([x-cx/4 + web, y-cy/4 + web, -1]) cylinder(h=ht, d=web, center=false);
    translate([x+cx/4 - web, y+cy/4 - web, -1]) cylinder(h=ht, d=web, center=false);
    translate([x+cx/4 - web, y-cy/4 + web, -1]) cylinder(h=ht, d=web, center=false);
  }
}

// These are the holes that will be used to mount the 'ears' that have the card guides.
// The holes go into the top and bottom edges ofthe frame.
// ofs : vector of offsets from left PCB edge to each hole
// r   : cylinder rotation about X axis (-90 for bottom holes. +90 for top holes
module edge_holes(ofs, y, z, r, ht, dia){
  union() {
    for(i = [0:len(ofs)-1]){
        translate([ofs[i], y,  z]) rotate(r, [1, 0, 0]) cylinder(h=ht, d=dia, center=false); 
    }
  }
  
}









//$fn = 40;

//lip_to_mod = (bp_hole_row3 - bp_hole_row2)/2 + bp_hole_row2 + mod_width/2 - mod_ofs - bp_height - edge[3];
//lip_z = lip_to_mod + cg_slot_gap + cg_depth;
//screw_cb = lip_z - attach_thick;

module ladoder() {
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
  translate([-34,-30,-10]) cube(size=[98.27,180,50]);  //0.5 recortado de -53.1
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
 }