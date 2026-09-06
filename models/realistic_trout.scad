// Realistic trout study. Millimetres; head is -X and dorsal is +Z.
// m3dscad WebUI: GPU (f32), Grid 280. No fn_solid.
// A smooth seed mesh is sculpted once, then converted to a GPU-ready SDF.
// Fin membranes are deliberately substantial enough for dual contouring.

seed_grid = 0.016;
scale_depth = 0.24;

function sq(x) = x*x;
function clamp01(x) = min(1,max(0,x));
function smooth01(x) = sq(clamp01(x))*(3-2*clamp01(x));
function cy(x) = 1.7*sin(1.7*(x+25));
function cz(x) = 1.4*sin(1.4*(x+8));
function tx(x) = (x+8)/70;
function side_y(x,z) = (14-7*tx(x))*sqrt(max(0,
    1-sq(tx(x))-sq((z-cz(x))/(24-7*tx(x)))));
function surface_point(x,z,s=1) = [x,cy(x)+s*side_y(x,z),z];

// Staggered, shallow scallops fade out over the head, belly, and tail wrist.
function scale_relief(x,a) = scale_cell(x,(a+180)/15);
function scale_cell(x,q) = scale_arc(x,q-floor(q)-0.5,
    (x+42)/5.2+0.5*(floor(q)%2));
function scale_arc(x,v,u) = scale_depth
    *exp(-sq(((u-floor(u))-(0.80-1.5*v*v))/0.16))
    *smooth01((x+40)/12)*smooth01((55-x)/14);
function sculpt(p) = sculpt_unit(p/norm(p));
function sculpt_unit(p) = sculpt_xyz(p,-8+70*p[0],
    atan2(p[2],p[1]));
function sculpt_xyz(p,x,a) = sculpt_finish(p,x,
    scale_relief(x,a)*(0.3+0.7*abs(cos(a))));
function sculpt_finish(p,x,d) = [x,
    cy(x)+(14-7*p[0])*p[1]-d*cos(atan2(p[2],p[1])),
    cz(x)+(24-7*p[0])*p[2]-d*sin(atan2(p[2],p[1]))];

module body() {
    solid() mesh_to_sdf()
        transform(function(p) sculpt(p))
            dual_contour(delta=seed_grid) sphere(1);
}

// Fin coordinates are in the anatomical side plane.
module membrane(outline,thickness=2.3) {
    rotate([90,0,0])
        inset_extrude(height=thickness,center=true,
            bottom=0.75,top=0.75,bottom_fn="fillet",top_fn="fillet")
            path_sdf(outline,segments=120);
}
function fin_wave(p,n) = [p[0],
    p[1]*(1+0.28*(1+cos(n==0 ?
        360*(p[0]-0.28*p[2])/5.3 : n*atan2(p[2],p[0]+8)))),p[2]];
module flowing_membrane(outline,thickness=2.5,waves=36) {
    // Smooth continuous corrugations form the rays in the membrane itself.
    solid() mesh_to_sdf()
        transform(function(p) fin_wave(p,waves))
            dual_contour(delta=0.38) membrane(outline,thickness);
}
module fin_rib(a,b,r=0.85) {
    v=b-a; d=norm(v);
    // A single tapered ellipsoid avoids small segment seams on oblique fins.
    for(s=[-1,1]) translate([(a[0]+b[0])/2,s*0.98,(a[1]+b[1])/2])
        rotate([0,atan2(v[0],v[1]),0])
            scale([r*1.7,1.22,d/2+0.3]) sphere(1);
}

module dorsal_fin() {
    translate([0,0.6,0]) {
        flowing_membrane("M-32 19 C-29 25 -26 34 -22 40 Q-20 43 -17 42 C-8 39 0 29 9 26 Q15 23 22 18 Q-3 21 -32 19 Z",2.3,0);
    }
}

module tail_fin() {
    translate([55,cy(55),0]) rotate([0,0,7]) {
        flowing_membrane("M-5 -5 C8 -8 18 -19 35 -25 Q40 -27 40 -23 C36 -14 29 -6 26 0 C29 6 37 15 40 23 Q41 27 36 25 C19 21 7 9 -5 6 Q-1 0 -5 -5 Z",2.5,48);
    }
}

module anal_fin() {
    translate([0,0.6,0]) {
        membrane("M16 -17 Q20 -25 26 -31 Q28 -33 31 -30 Q37 -24 45 -14 Q30 -17 16 -17 Z");
        for(i=[0:5]) {
            t=i/5;
            fin_rib([18+23*t,-16],[27+15*t,-30+13*t],0.8);
        }
    }
}

module adipose_fin() {
    translate([0,1.6,0])
        membrane("M33 14 Q33 22 37 23 Q41 25 43 19 Q45 15 49 11 Q40 14 33 14 Z",2.8);
}

// Paired fins are swept backwards and spread away from the belly.
module paired_fin(p,tilt,size=1) {
    translate(p) rotate([tilt,0,0]) scale([size,size,size]) {
        flowing_membrane("M-2 2 Q3 3 7 -1 C13 -6 21 -14 25 -19 Q27 -22 23 -21 C13 -18 3 -13 0 -7 Q-2 -2 -2 2 Z",2.3,56);
    }
}

module fins() {
    dorsal_fin(); tail_fin(); anal_fin(); adipose_fin();
    for(s=[-1,1]) {
        paired_fin([-37,cy(-37)+s*12,-7],s*48,1);
        paired_fin([3,cy(3)+s*7,-18],s*33,0.70);
    }
}

module eyes() {
    for(s=[-1,1]) {
        translate(surface_point(-58,7,s)+[0,-s*0.65,0])
            scale([1,0.72,1]) sphere(4.0);
    }
}

module gill_lines() {
    for(s=[-1,1]) {
        // The crescent stops short of the back and throat: no encircling seam.
        line_join([for(i=[0:24])
            surface_point(-44+10*sin(180*i/24),18-35*i/24,s)],r=0.68);
        // A short preopercular fold gives the cheek its layered anatomy.
        line_join([for(i=[0:13])
            surface_point(-47+4*sin(170*i/13),9-22*i/13,s)],r=0.38);
    }
}

module mouth() {
    // Closed mouth slopes gently back to the jaw hinge on both cheeks.
    for(s=[-1,1])
        line_join([for(i=[0:30])
            surface_point(-77.8+24*i/30,-1.4-3.1*sin(90*i/30),s)],r=0.66);
}

module lateral_lines() {
    for(s=[-1,1])
        line_join([for(i=[0:50])
            surface_point(-29+80*i/50,3.8-3.0*i/50,s)],r=0.34);
}

difference() {
    union() { body(); fins(); eyes(); }
    gill_lines(); mouth(); lateral_lines();
    for(s=[-1,1]) {
        // Circular pupils recessed just into the convex eye surface.
        translate(surface_point(-58,7,s)+[-0.25,s*2.08,0.12])
            scale([1,0.48,1]) sphere(2.05);
        // Small paired nares above and ahead of the eye.
        translate(surface_point(-65,7.5,s))
            scale([1.2,0.85,0.75]) sphere(0.9);
    }
}
