include <s100_defs18-2c.scad>

$fn = 40;

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
 difference(){
  // Additions (baseplate + bosses) //19.05
  union(){
    baseplate(bp_width, bp_height, base_thick+1.5); //plataforma base
    //soporte tornillo imsai dcho
    //bosses(bm_holes,  boss_dia, bp_hole_row1, 0, base_thick+boss_thick);          // Bot mounting bosses
    //soporte tornillo altair dcho
    bosses(slot_ofs,  boss_dia, bp_hole_row2, 0, base_thick+boss_thick);          // Bot card connector bosses
    //soporte tornillo central dcho
    translate ([-19.05,0,0]) bosses(mid_holes, boss_dia, bp_hole_row2, 0, base_thick+boss_thick);          // Bot boss between slots 4 & 5
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
      //agujeros derecha paso 3mm //3.2 o 3.1
    translate ([70,-3,10]) rotate([90,0,0]) cylinder(h=10, d=3.1, center=false);
    translate ([98,-3,10]) rotate([90,0,0]) cylinder(h=10, d=3.1, center=false);
   

  }
  
  // Removals (holes + cutouts)
  // agujeros imsai dcho
  translate ([19.05,0,0]) bosses(bm_holes,  screw_threads, bp_hole_row1, -1, base_thick+boss_thick+2);      // Bot mounting holes
  // agujeros altair dcho
  bosses(slot_ofs,  screw_threads, bp_hole_row2, -1, base_thick+boss_thick+2);      // Bot card connector holes
  //agujero central dcho
  translate ([-19.05,0,0]) bosses(mid_holes, screw_threads, bp_hole_row2, -1, base_thick+boss_thick+2);      // Bot hole between slots 4 & 5
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
  translate([-34.04,-30,-10]) cube(size=[98.27,280,50]);  //0.5 recortado de -53.1
  //cutout trasero
  translate([102.3,-30,-10]) cube(size=[98,280,50]);  //101.8 o 102.3
  //#translate ([0,145,1]) attach_holes(1); // agujero central
  translate ([-20,-20,-6]) cube([bp_width+40, bp_height+40, base_thick+4]); 
  //cutout lateral deja lado derecho
  translate([-33.25,+50,-10]) cube(size=[800,280,50]);  //0.5 recortado de -53.1
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
