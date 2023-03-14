$fn=100;

CRIMPER = "SN28B"; // Either "SN58B" or "SN28B"
assert(CRIMPER == "SN58B" || CRIMPER == "SN28B",
    "CRIMPER set to improper value");
TYPE = "DUPONT";
assert(TYPE == "DUPONT" || TYPE == "JST_XH_2_54" || TYPE == "JST_SM_2_5",
    "TYPE set to improper value");

// For IWISS SN-58B

lip_len = CRIMPER == "SN28B"? 22 : 24.25;
lip_h = 3; // Without teeth
lip_overhang = 2.3;
lip_w = 7.25;
front_to_first = CRIMPER == "SN28B"? 5.8 : 3.7;
h_first = 2.30;
max_jaw_h = 14.3;
min_jaw_h = 11.0;
jaw_w = 9.5;

screw_d = 7.9;
screw_h = 2;
front_to_screw =  CRIMPER == "SN28B"? 8.5 : 10.5;
screw_to_lip = 1.1;

thk = screw_h; // Thickness of outer walls.

holder_h = lip_h+max_jaw_h+thk;
holder_w = jaw_w + 2*thk;
holder_len = lip_len+thk;

module bevel_on_y(x, y) {
    translate([0, 0, -x])
        rotate([90, 0, 90])
            linear_extrude(x) {
                polygon(points=[[0,0], [0, x], [y, x]]);
            }
}

module dupont() {
    hole_sz = 2;
    pin_sz = 1;
    hole_depth = 5;
    z = hole_sz+thk+h_first;
    x = 2*thk+front_to_first*2;
    y = hole_depth+thk;
    translate([0, holder_w-thk, holder_h]) {
        difference() {
            cube([x, y, z]);
            translate([front_to_first+thk-hole_sz/2, -1, h_first])
                cube([hole_sz, hole_depth+1, hole_sz]);
            translate([front_to_first+thk-pin_sz/2, -1, h_first])
                cube([pin_sz, hole_depth*4+1, pin_sz]);
        }
        bevel_on_y(x, y);
    }    
}

module jst_sm_2_5() {
    hole_h = 3.5;
    hole_w = 2.1;
    hole_depth = 2;
    pin_h = 1.2;
    pin_w = 2;
    z = hole_h+thk+h_first;
    x = 2*thk+front_to_first*2;
    y = hole_depth+thk;
    translate([0, holder_w-thk, holder_h]) {
        difference() {
            cube([x, y, z]);
            translate([front_to_first+thk-hole_w/2, -1, h_first])
                cube([hole_w, hole_depth+1, hole_h]);
            translate([front_to_first+thk-pin_w/2, -1, h_first])
                cube([pin_w, hole_depth*4+1, pin_h]);
        }
        bevel_on_y(x, y);
    }    
}

module jst_xh_2_54() {
    hole_h = 3;
    hole_w = 2;
    hole_depth = 2;
    z = hole_h+thk+h_first;
    x = 2*thk+front_to_first*2;
    y = hole_depth+thk;
    translate([0, holder_w-thk, holder_h]) {
        difference() {
            cube([x, y, z]);
            translate([front_to_first+thk-hole_w/2, -1, h_first])
                cube([hole_w, hole_depth+1, hole_h]);
        }
        bevel_on_y(x, y);
    }    
}

module lip() {
    cube([lip_len+1, lip_h+1, lip_w]);
    translate([0, -min_jaw_h, 0])
        cube([lip_overhang+lip_len+1, min_jaw_h, lip_w]);
}

module jaw() {
    linear_extrude(jaw_w) {
        h = max_jaw_h;
        min_bot = h-min_jaw_h;
        l = lip_len+1;
        polygon(points=[[0, min_bot], [0, h], [l, h],
            [l, 0]]);
    }
}

module screw_slot() {
    r = screw_d/2;
    translate([r, r, -1])
        cylinder(r=r, h=screw_h+2);
    translate([r, 0, -1])
        cube([lip_len, r*2, screw_h+2]);
}

module round_corner_untrimed(r) {
    translate([0, 0, (holder_w+2)/2]) {
        difference() {
            cube([r*2, r*2, holder_w+2], center=true);
            translate([0, 0, -(holder_w+4)/2])
                cylinder(r=r, h=holder_w+4);
        }
    }
}

module round_corner() {
    r = 8;
    translate([r, r, 0])
    difference() {
        round_corner_untrimed(r);
        translate([-r, -1, -1])
            cube([r*2+2, r+2, holder_w+4]);
        translate([0, -r-1, -1])
            cube([r+2, r+1, holder_w+4]);
    }
}


module holder() {
    translate([0, holder_w, 0]) rotate([90, 0, 0]) difference() {
        cube([holder_len, holder_h, holder_w]);
        translate([thk, holder_h-lip_h, (holder_w-lip_w)/2]) lip();
        translate([thk, thk, (holder_w-jaw_w)/2]) jaw();
        translate([front_to_screw+thk,
            holder_h-lip_h-screw_to_lip-screw_d, holder_w-thk])
            screw_slot();
        round_corner();
    }
}

rotate([0, -90, -45]) {
    if (TYPE == "DUPONT") {
        dupont();
    } else if (TYPE == "JST_XH_2_54") {
        jst_xh_2_54();
    } else { // TYPE == JST_SM_2_5
        jst_sm_2_5();
    }
    holder();
}
