// Raspberryp PI Compute Module 4 IO board enclosure. 
// I use PrusaSlicer to cut before printing and also to turn the lid upside-down.
// The x and y should nowbe parametric and some comments added. Enjoy.
m=4;
s=1.5;
k=12;
$fn=30;
depth=92;
hole=2;
length=162;
cpudepth=41;
cpuLength=91;
elevation=1;

difference(){
    union(){   //main block to be subtracted from
        translate([0,0,-m])
            minkowski(){
                cube([depth,length, 25]);
                cylinder(25,m,m);
            }
    }
    
    //cutout in lid to fit box
    translate([m/2,m/2,34])
        minkowski(){
            cube([depth-m+0.2,length-m+0.2, 2]);
            cylinder(2,m,m);
        }
    union(){
        cube([depth,length,42]); //inner cube this was too tight at first version. sorry.

        // Side panel holes for connectors
        translate([depth,23,7+elevation])
            cube([20,18,11],center=true);
        translate([depth,48,7+elevation])
            cube([20,18,11],center=true);
        translate([depth,74,10+elevation])
            cube([20,15,18],center=true);
        translate([depth,93,10+elevation])
            cube([20,15,18],center=true);
        translate([depth,107.7,5+elevation])
            cube([20,10,7],center=true);
        translate([depth,122.5,5+elevation])
            cube([20,17,6],center=true);
        translate([depth,154,10+elevation])
            cube([20,13,13],center=true);
            
        // hole in middle of lid for cooling of SOC with holes on 4 sides
        translate([cpudepth,cpuLength,28])
            cylinder(40,2,2,center=true);
        translate([cpudepth,cpuLength,46])
            cylinder(6,2,6,center=true); 
        translate([cpudepth+k,cpuLength+k,42])
            cylinder(4,6,4,center=true);
        translate([cpudepth-k,cpuLength+k,42])
            cylinder(4,6,4,center=true); 
        translate([cpudepth+k,cpuLength-k,42])
            cylinder(4,6,4,center=true); 
        translate([cpudepth-k,cpuLength-k,42])
            cylinder(4,6,4,center=true);

        for (i=[0:5:80]){    //cooling holes in this for loop
            translate([5+i,20,23])
                rotate([-60,0,0])
                    cube([2,11,150], center=true);
            translate([5+i,140,30])
                rotate([50,0,0])
                    cube([2,10,150], center=true);  
        }

        // feet indentations 
        translate([hole+s,hole+s,-5])
            cylinder(4,3*s,2*s,center=true);
        translate([depth-hole-s,hole+s,-5])
            cylinder(4,3*s,2*s,center=true);
        translate([hole+s,length-hole-s,-5])
            cylinder(4,3*s,2*s,center=true);
        translate([depth-hole-s,length-hole-s,-5])
            cylinder(4,3*s,2*s,center=true);
 
        translate([50,50,32])
            cube([2000,1000,5],center=true); //Gap under lid

        difference(){ //complicated way of making ridge on box to fit the lid.
            translate([0,0,26])
                minkowski(){
                    cube([depth+m,length+m, 2]);
                    cylinder(2,m,m);
                }

            //still the ridge
            translate([m/2+s/2,m/2+s/2,26])
                minkowski(){
                    cube([depth-m-s,length-m-s, 2]);
                    cylinder(2,m,m);
                }
        }
    
        //screw holes for wood screws
        translate([hole,hole,38])
            cylinder(30,hole,hole,center=true);
        translate([depth-hole,hole,38])
            cylinder(30,hole,hole,center=true);
        translate([hole,length-hole,38])
            cylinder(30,hole,hole,center=true);
        translate([depth-hole,length-hole,38])
            cylinder(30,hole,hole,center=true);
        translate([hole,hole,46])
            cylinder(6,1,6,center=true);
        translate([depth-hole,hole,46])
            cylinder(6,1,6,center=true);
        translate([hole,length-hole,46])
            cylinder(6,1,6,center=true);
        translate([depth-hole,length-hole,46])
            cylinder(6,1,6,center=true);

    }
}

difference(){
    union(){ //screw holes
        translate([hole,hole,26])
            cylinder(7,2*s,2*s,center=true);
        translate([depth-hole,hole,26])
            cylinder(7,2*s,2*s,center=true);
        translate([hole,length-hole,26])
            cylinder(7,2*s,2*s,center=true);
        translate([depth-hole,length-hole,26])
            cylinder(7,2*s,2*s,center=true);
    }
    //screw holes 
    translate([hole,hole,35])
        cylinder(30,s,s,center=true);
    translate([depth-hole,hole,35])
        cylinder(30,s,s,center=true);
    translate([hole,length-hole,35])
        cylinder(30,s,s,center=true);
    translate([depth-hole,length-hole,35])
        cylinder(30,s,s,center=true);

    // spherical cutouts to avoid support needs. Quite pleased with these.
    translate([2*hole,2*hole,22])
        sphere(4); 
    translate([depth-2*hole,2*hole,22])
        sphere(4); 
    translate([2*hole,length-2*hole,22])
        sphere(4); 
    translate([depth-2*hole,length-2*hole,22])
        sphere(4);  
}
