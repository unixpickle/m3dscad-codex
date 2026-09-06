// Realistic field pumpkin, millimetres.
// Compile in app.m3dscad.com with GPU (f32), grid 280.
// Smooth seed meshes are deformed once, then converted to GPU-ready SDFs.
// No fn_solid or per-voxel interpreted functions are used.

body_radius = 78;
body_sampling = 0.022;
stem_sampling = 0.04;

function angle(p) = atan2(p[1],p[0]);
// Ten broad ribs, rounded valleys, a slight twist and unequal growth.
function rib(p) = 1 + 0.058*cos(10*angle(p)+8*p[2])
    - 0.012*cos(20*angle(p)+16*p[2])
    + 0.012*sin(3*angle(p)+25) + 0.009*cos(angle(p)-40);
function pumpkin_point(p) = [
    body_radius*p[0]*rib(p)*(1-0.025*p[2]),
    body_radius*0.96*p[1]*rib(p)*(1-0.025*p[2]),
    54 + 63.5*p[2] + 2.5*p[2]*p[2]
       + (p[2]>=0 ? -19*pow(p[2],14) : 10*pow(-p[2],12))
       + 1.3*p[0] - 0.7*p[1]
];

module pumpkin_body() {
    solid() mesh_to_sdf()
        transform(function(p) pumpkin_point(p))
            dual_contour(delta=body_sampling) sphere(r=1);
}

// The root flares into the dimple. Five substantial woody flutes follow
// the bend; an angled, softly bevelled cut gives the stem a natural end.
function stem_x(t) = 17*t*t-4*t;
function stem_y(t) = 3*sin(100*t);
function stem_r(t) = 6.1 + 8.5*pow(1-t,4) + 0.35*sin(150*t);
function stem_flute(p) = 1 + 0.12*cos(5*angle(p))
                            + 0.025*sin(3*angle(p)+40);
function stem_point(p) = [
    stem_x(p[2]) + stem_r(p[2])*stem_flute(p)
        *(p[0]*cos(22*p[2])-p[1]*sin(22*p[2])),
    stem_y(p[2]) + stem_r(p[2])*stem_flute(p)
        *(p[0]*sin(22*p[2])+p[1]*cos(22*p[2])),
    98 + 37*p[2] - 1.4*p[0]*pow(p[2],3)
];

module pumpkin_stem() {
    solid() mesh_to_sdf()
        transform(function(p) stem_point(p))
            dual_contour(delta=stem_sampling)
                solid() inset_extrude(height=1, top=0.055, top_fn="fillet")
                    circle_sdf(r=1);
}

union() {
    pumpkin_body();
    pumpkin_stem();
}
