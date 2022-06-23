// Raspberry PI Compute Module 4 IO board enclosure. 
// The x and y should nowbe parametric and some comments added. Enjoy.
include <BOSL/constants.scad>
use <BOSL/metric_screws.scad>
use <explode.scad>

/*[View]*/
// Exploded or Assembled view for reviewing project and Printable base and Printable lid to select individual parts to print.
Project_View = 4;   // [ 0:Select View,1:Exploded View,2:Assembled View,3:Printable base,4:Printable lid,5:Printable Lid extension,6:Printable Display Mount ]

/*[Options]*/
// No MMC, enable uSDCard
CM4_Lite = false;
// PCIe Support
PCIe_Option = 1;    // [ 0:None,1:Standard NVME Storage, 2:Other ]
// Display mounted on case lid
Builtin_Display = true;
// Add fan grill to case
Fan_Support = true;
// External antenna for WiFi, Z-wave, etc
External_Antenna = true;

/*[Advanced]*/
// Fan Grill Number of sections
Grill_Sections = 4;                  // 2
// Fan Grill Bands Width
Grill_Bands_Width = 3;
// Thickness of the walls, bottom and lid
Shell_Thickness = 3;

// Length of the CM4 I/O Board
Board_Length = 160;
// Depth of the CM4 I/O Board
Board_Depth = 90;


// Board_Length + 5
Box_Length = 165;
// Board_Depth + 5 + (Builtin_Display ? 35)
Box_Depth = 130;
//  Shell_Thickness (Bottom) + 1.5 (I/O Board Height) + 20 (highest connector) + 6.5 (buffer till lid) + 2 (half of interlock between base and lid)
Box_Height = 33;

// Height of Lid
Lid_Height = 8;

// Length of Lid Extension (Box_Depth - Shell_Thickness, MAX 108)
Extension_Length = 106;
// Depth of Lid Extension
Extension_Depth = 14;
// Height of Lid Extension
// Extension_Height = 40;
Extension_Height = 40;

Display_Width = 68;
Display_Height = 106;

/*[Hidden]*/
$fn=30;

cutouts = [
//  [ horiz, vert,  width,  height ]
    [ 23,    0,     16,     7 ],    // HDMI0
    [ 10.7,  0,     1.5,    1 ],    // LED0
    [ 3.65,  0,     1.5,    1 ],    // LED1
    [ 10.65, 0,     16,     7 ],    // HDMI1
    [ 26,    0,     17,     14 ],   // Ethernet
    [ 19,    0,     15,     17 ],   // USB
    [ 15,    0,     9,      4 ],    // USBSlave
    [ 13.25, 0,     13,     2 ],    // uSDCard
    [ 33,    0,     12,     12 ]    // Power
];

cutout_index_HDMI0 = 0;
cutout_index_LED0 = 1;
cutout_index_LED1 = 2;
cutout_index_HDMI1 = 3;
cutout_index_Ethernet = 4;
cutout_index_USB = 5;
cutout_index_USBSlave = 6;
cutout_index_uSDCard = 7;
cutout_index_Power = 8;

offsets = [for (i = 1, t = cutouts[0][0]; i <= 9; t = t + (i <= 8 ? cutouts[i][0] : 0), i = i + 1) t];

ext_antenna_offset = 35;

PCIe_offset = 130;

hat_mounts = [
    [ 3.5,  3.5 ],
    [ 3.5,  52.5 ],
    [ 61.5, 52.5 ],
    [ 61.5, 3.5 ]
];

board_mounts = [
    [ 11,  8 ],
    [ 145, 8 ],
    [ 11,  77 ],
    [ 145, 77 ]
];

lid_mounts = [
    [ -Box_Length / 2 + 3.5,    -Box_Depth / 2 + 3.5 ],
    [ -Box_Length / 2 + 3.5,    Box_Depth / 2 - 3.5 ],
    [ Box_Length / 2 - 3.5,     -Box_Depth / 2 + 3.5 ],
    [ Box_Length / 2 - 3.5,     Box_Depth / 2 - 3.5 ]
];

module base() {
    
    difference(){
        // Main block to be subtracted from
        minkowski(){
            cube([Box_Length, Box_Depth, Box_Height / 2], center=true);
            cylinder(Box_Height / 2, r = Shell_Thickness, center=true);
        }

        union(){
            // Hollow out interior
            translate([0, 0, Shell_Thickness]) {
                cube([Box_Length, Box_Depth, Box_Height], center=true);
            }


            //translate([0, -Box_Depth / 2 + Shell_Thickness / 2])
            //#cube([6, 3, 7.5], center=true);
            
            // Connector cutouts
            echo(offsets);
            for (index = [0:8]) {
                translate([Box_Length / 2 - 1 - offsets[index], Box_Depth / 2 + Shell_Thickness / 2, -Box_Height / 2 + cutouts[index][1] + cutouts[index][3] / 2 + 3 * Shell_Thickness + 1.5]) {
                    cube([cutouts[index][2], Shell_Thickness + 2, cutouts[index][3]], center=true);
                }
            }

            if (External_Antenna) {
                // Z-Wave Antenna
                translate([Box_Length / 2 - 1 - ext_antenna_offset, Box_Depth / 2 + Shell_Thickness / 2, 8]) {
                    rotate([90, 0, 0]) {
                        cylinder(Shell_Thickness + 2, r = 3.5, center=true);
                    }
                }
            }
            
            // Side cooling holes
            cooling_length = Box_Height - 4 * Shell_Thickness;
            cooling_offset = 3 * Shell_Thickness - 2;

            for (index = [0:15:90]){
                translate([0, Box_Depth / 2 - 15 - index, -Box_Height / 2 + cooling_offset + cooling_length / 2]) {
                    rotate([0, 90, 0]) {
                        minkowski() {
                            cube([cooling_length / 2, Shell_Thickness / 2, Box_Length + Shell_Thickness], center=true);
                            cylinder(2 * Shell_Thickness, r = Shell_Thickness / 2, center=true);
                        }
                    }
                }
            }

/*
            // Feet indentations 
            translate([-Box_Length / 2 + hole + s, -Box_Depth / 2 + hole + s, -30])
                cylinder(4, 3 * s, 2 * s, center=true);
            translate([-Box_Length / 2 + hole + s, Box_Depth / 2 - hole - s, -30])
                cylinder(4, 3 * s, 2 * s, center=true);
            translate([Box_Length / 2 - hole - s, -Box_Depth / 2 + hole + s, -30])
                cylinder(4, 3 * s, 2 * s, center=true);
            translate([Box_Length / 2 - hole - s, Box_Depth / 2 - hole - s, -30])
                cylinder(4, 3 * s, 2 * s, center=true);
*/
            
            // Complicated way of making ridge on box to fit the lid.
            difference(){
                translate([0, 0, Box_Height / 2]) {
                    minkowski(){
                        cube([Box_Length + Shell_Thickness / 2, Box_Depth + Shell_Thickness / 2, 2], center=true);
                        cylinder(2, r=Shell_Thickness, center=true);
                    }
                }

                // Still the ridge
                translate([0, 0, Box_Height / 2]) {
                    minkowski(){
                        cube([Box_Length - Shell_Thickness, Box_Depth - Shell_Thickness, 2], center=true);
                        cylinder(2, r=Shell_Thickness, center=true);
                    }
                }
            }
        }
    }

    // Lid Attachment
    for (index = [0:3]) {
        translate([lid_mounts[index][0], lid_mounts[index][1], Box_Height / 2 - 3]) {
            difference() {
                cube([8, 8, 4], center=true);
                translate([0, 0, 11])
                    metric_bolt(size=3.25, headtype="countersunk", l=12, details=false, coarse=false);
            }
        }
    }
    
    // Board mounts
    for (index = [0:3]) {
        translate([Box_Length / 2 - 1 - board_mounts[index][0], Box_Depth / 2 - board_mounts[index][1], -Box_Height / 2 + 2 * Shell_Thickness]) {
            mount();
        }
    }

    // HAT mounts
    for (index = [0:3]) {
        translate([Box_Length / 2 - hat_mounts[index][0], Box_Depth / 2 - hat_mounts[index][1], -Box_Height / 2 + 2 * Shell_Thickness]) {
            mount();
        }
    }
}

module mount() {
    difference() {
        cylinder(h = 2 * Shell_Thickness, r = 2.5, center=true);
        translate([0, 0, -2 * Shell_Thickness / 2 + 6])
            metric_bolt(size=2.5, headtype="cap", l=6, details=false, coarse=true);
    }
}

module display_mount() {
    // 13 = 3 outer shell +   14
    difference() {
        cube([14, 14, 14], center=true);
        translate([-2, -2, 2]) {
            cube([12, 12, 12], center=true);
        }
        translate([0, 0, 0]) {
            rotate([0, 0, 0])  
                metric_bolt(size=3.5, headtype="cap", l=12, details=false);
        }
    }
}

module fan_grill_cutout() {
    difference() {
        cube([40, 40, Shell_Thickness+2], center=true);
        difference() {
            cube([41, 41, Shell_Thickness + 3], center=true);
            union() {
                translate([-15, -15, 0])
                    cylinder(h=Shell_Thickness + 3, d=5, center=true);
                translate([-15, 15, 0])
                    cylinder(h=Shell_Thickness + 3, d=5, center=true);
                translate([15, -15, 0])
                    cylinder(h=Shell_Thickness + 3, d=5, center=true);
                translate([15, 15, 0])
                    cylinder(h=Shell_Thickness + 3, d=5, center=true);

                // Fan hole
                cylinder(Shell_Thickness + 3, d=35, center=true);
            }
        }

        // Grill
        union() {
            for (index=[3:3:9]) {
                difference() {
                    cylinder(d=Grill_Bands_Width+(index+1)*Grill_Bands_Width,h=Shell_Thickness+2,center=true);
                    cylinder(d=Grill_Bands_Width+index*Grill_Bands_Width,h=Shell_Thickness+3,center=true);
                }
            }

            degrees = 180 / (Grill_Sections / 2);

            for (angle = [0:degrees:360/2-degrees]) {
                rotate([0,0,angle]) {
                    cube([37,Grill_Bands_Width/2,Shell_Thickness+2],center=true);
                }
            }
        }
    }
}

module lid() {
//    translate([Box_Length / 2 - 20, 0, Lid_Height / 2 - Shell_Thickness - 0.5])
//        cube([2, 99.3, 8], center=true);
//
//    translate([40, 50, Lid_Height / 2 - Shell_Thickness - 0.5])
//        cube([61.8, 2, 8], center=true);
    difference(){
        // Main block to be subtracted from
        minkowski(){
            cube([Box_Length, Box_Depth, Lid_Height / 2], center=true);
            cylinder(Lid_Height / 2, r=Shell_Thickness, center=true);
        }

        // Hollow out lid
        translate([0, 0, -Shell_Thickness])
            cube([Box_Length, Box_Depth, Lid_Height], center=true); //inner cube this was too tight at first version. sorry.

        // Cutout in lid to fit box
        translate([0, 0, -Lid_Height / 2 + 0.5]) {
            minkowski(){
                cube([Box_Length, Box_Depth, 2], center=true);
                cylinder(1, r = Shell_Thickness / 2, center=true);
            }
        }

        // Lid Mount
        for (index = [0:3]) {
            translate([lid_mounts[index][0], lid_mounts[index][1], Shell_Thickness]) {
                metric_bolt(size=3.25, headtype="countersunk", l=12, details=false, coarse=false);
            }
        }

        if (Fan_Support) {
            translate([-Box_Length / 2 + 65, Box_Depth / 2 - Board_Depth + 10, Shell_Thickness / 2])
                fan_grill_cutout();
        }
        
        if (PCIe_Option != 0) {
            // PCIe Cutout
            translate([Box_Length / 2 - 130, Box_Depth / 2 - Extension_Length / 2 + 1, Lid_Height / 2 - Shell_Thickness]) {
                cube([Extension_Depth + 1, Extension_Length - Shell_Thickness, (Lid_Height + 2) ], center=true);
            }

            // Front Left
            translate([Box_Length / 2 - 130 - 10, Box_Depth / 2 - Extension_Length + Shell_Thickness + 4, Lid_Height / 2 - Shell_Thickness / 2 + 4]) {
                metric_bolt(size=3.25, headtype="countersunk", l=12, details=false, coarse=false);
            }
            // Front Right
            translate([Box_Length / 2 - 130 + 10, Box_Depth / 2 - Extension_Length + Shell_Thickness + 4, Lid_Height / 2 - Shell_Thickness / 2 + 4]) {
                metric_bolt(size=3.25, headtype="countersunk", l=12, details=false, coarse=false);
            }
            // Rear Left
            translate([Box_Length / 2 - 130 - 10, Box_Depth / 2 - 5, Lid_Height / 2 - Shell_Thickness / 2 + 4]) {
                metric_bolt(size=3.25, headtype="countersunk", l=12, details=false, coarse=false);
            }
            // Rear Right
            translate([Box_Length / 2 - 130 + 10, Box_Depth / 2 - 5, Lid_Height / 2 - Shell_Thickness / 2 + 4]) {
                metric_bolt(size=3.25, headtype="countersunk", l=12, details=false, coarse=false);
            }
        }

        if (Builtin_Display) {
            // Display
            translate([Box_Length / 4 + 2, 0, Lid_Height / 2 - Shell_Thickness / 2 + 0.5 - 0.5]) {
                cube([70, 108, Shell_Thickness + 1],center=true);
            }
        }
    }
    
//    #translate([Box_Length / 2 - 20, 0, -14]) {
//        cube([4, 99.3, 4], center=true);
//}

    if (Builtin_Display) {
        // Display Mounts
        translate([Box_Length / 4 + 2, 0, Lid_Height / 2 - Shell_Thickness + 1]) {
            union() {
                translate([(70 - 8.2) / 2, (108 - 8.7) / 2, -8])
                    display_mount();
                translate([-(70 - 8.2) / 2, (108 - 8.7) / 2, -8])
                    rotate([0, 0, 90])
                        display_mount();
                translate([(70 - 8.2) / 2, -(108 - 8.7) / 2, -8])
                    rotate([0, 0, -90])
                        display_mount();
                translate([-(70 - 8.2) / 2, -(108 - 8.7) / 2, -8])
                    rotate([0, 0, 180])
                        display_mount();
            }
        }
    }
}

module lid_extension() {
    difference() {
        cube([Extension_Depth, Extension_Length, Extension_Height], center=true);
        translate([0, 0, -Shell_Thickness - 0.5])
            cube([Extension_Depth - 2 * Shell_Thickness, Extension_Length - 2 * Shell_Thickness, Extension_Height - Shell_Thickness + 1], center=true);
        translate([0, -Extension_Length / 2 + (Shell_Thickness + 1) / 2 - 0.1, -Extension_Height / 2 + Shell_Thickness / 2])
            cube([Extension_Depth + 0.1, Shell_Thickness + 1.1, Shell_Thickness + 0.1], center=true);
    }

    // Rear Right
    translate([-Extension_Depth / 2 - 6 / 2, -Extension_Length / 2 + Shell_Thickness + 1 + 8 / 2, -Extension_Height / 2 + 1.5 * Shell_Thickness])
        difference() {
            cube([9, 8, 3], center=true);
            translate([-0.5, 0, 0.5])
                metric_bolt(size=3.25, headtype="countersunk", l=10, details=false, coarse=false);
        }
        
    // Rear Left
    translate([Extension_Depth / 2 + 6 / 2, -Extension_Length / 2 + Shell_Thickness + 1 + 8 / 2, -Extension_Height / 2 + 1.5 * Shell_Thickness])
        difference() {
            cube([9, 8, 3], center=true);
            translate([0.5, 0, 0.5])
                metric_bolt(size=3.25, headtype="countersunk", l=10, details=false, coarse=false);
        }
        
    // Front Right
    translate([-Extension_Depth / 2 - 8 / 2, Extension_Length / 2 - 8 / 2, -Extension_Height / 2 + 1.5 * Shell_Thickness])
        difference() {
            cube([9, 8, 3], center=true);
            translate([-0.5, 0, 0.5])
                metric_bolt(size=3.25, headtype="countersunk", l=10, details=false, coarse=false);
        }
        
    // Front Left
    translate([Extension_Depth / 2 + 8 / 2, Extension_Length / 2 - 8 / 2, -Extension_Height / 2 + 1.5 * Shell_Thickness])
        difference() {
            cube([9, 8, 3], center=true);
            translate([0.5, 0, 0.5])
                metric_bolt(size=3.25, headtype="countersunk", l=10, details=false, coarse=false);
        }
}

if (Project_View == 1) {
    //  Exploded View
    explode([30, 30, 30], false, true, $fn=15) {
        rotate([22.5,0,0])
            translate([0, 0, Box_Height / 2])
                base($fn=15);

        rotate([22.5,0,0])
            translate([0, 0, Box_Height + 4])
                lid($fn=15);

        rotate([22.5,0,0])
            translate([-61, 0, Box_Height + Extension_Height / 2 - 2])
                lid_extension($fn=15);
    }
} else if (Project_View == 2) {
    // Assembled View
    color("green") translate([0, 0, Box_Height / 2])
        base($fn=15);

    color("orange") translate([0, 0, Box_Height + Lid_Height / 2 - 1])
        lid($fn=15);

    color("blue") translate([-61, 10, Box_Height + Lid_Height + Extension_Height / 2 - 4])
        lid_extension($fn=15);
} else if (Project_View == 3) {
    // Printable Base
    translate([0, 0, Box_Height / 2])
        base();
} else if (Project_View == 4) {
    // Printable Lid
    translate([0, 0, Lid_Height / 2])
        rotate([0, 180, 0])
            lid();
} else if (Project_View == 5) {
    // Printable Lid Extension
    translate([0, 0, Extension_Height / 2])
        rotate([0, 180, 0])
            lid_extension();
} else if (Project_View == 6) {
    // Printable Display Mount
 //   translate([0, 0, 0])
//        rotate([0, 180, 0])
//        difference() {
//            cube([40, 40, Shell_Thickness], center=true);
    fan_grill_cutout();
//        }
}
