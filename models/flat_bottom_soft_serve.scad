// Freestanding soft-serve cone. Dimensions are millimetres.
// Compile in app.m3dscad.com using GPU (f32), Grid 280.
// Uses GPU-supported primitives throughout; no fn_solid or custom transform.

cone_height = 60;
base_radius = 11.5;
rim_radius = 23;
spiral_samples = 96;

function cone_r(z) = base_radius+(rim_radius-base_radius)*z/cone_height;
function coil_r(t) = t<0 ? 18-18*t/3.9-70*t*t : 18*(1-t/3.9);
function rope_r(t) = 8.6-1.15*max(0,t);
function coil_z(t) = 66+14.2*t-1.05*t*t;
function coil_point(t) = [coil_r(t)*cos(360*t+20),
                          coil_r(t)*sin(360*t+20), coil_z(t)];
function tip_point(u) = coil_point(3.65)+[5.4*u*u,2*u,9.5*u];
function tip_radius(u) = rope_r(3.65)*(1-u)+0.85*u;

// Gaussian line integration produces a continuous cream surface without
// sphere-chain scallops. Arc-length weighting keeps its thickness uniform.
module cream_sample(p,q,r) {
    sigma = r/2;
    weight_metaball(norm(q-p)/(1.77245385*sigma))
        translate((p+q)/2) scale([sigma,sigma,sigma]) sphere_metaball(r=0);
}

module waffle_cone() {
    // Full flat disk, with a gently bevelled perimeter, for standing upright.
    rotate_extrude() polygon([
        [0,0], [10.8,0], [11.35,0.35], [11.7,1.05],
        [23,60], [0,60]
    ]);

    // Rounded diagonal ribs are embedded in the solid cone.
    for (hand = [-1,1])
        translate([0,0,3])
            linear_extrude(height=54,twist=hand*210,
                           scale=(cone_r(57)-0.2)/(cone_r(3)-0.2))
                union() {
                    for (a = [0:30:330])
                        translate([(cone_r(3)-0.2)*cos(a),(cone_r(3)-0.2)*sin(a)])
                            circle(r=0.72);
                }

    rotate_extrude() translate([22.8,59.5]) circle(r=1.5);
}

module soft_serve() {
    translate([0,0,58]) cylinder(h=49,r1=16,r2=0.5);

    // The first end is tucked into the cone. Neighbouring turns blend
    // softly while retaining the characteristic piped spiral valleys.
    metaball_solid(2,falloff="gaussian") {
        // Blend the seated cream into its first turn without a hard seam.
        translate([0,0,61]) scale([11.4,11.4,3.42])
            sphere_metaball(r=0);
        for (i = [0:spiral_samples-1]) {
            t = -0.4+4.05*i/spiral_samples;
            s = -0.4+4.05*(i+1)/spiral_samples;
            cream_sample(coil_point(t),coil_point(s),rope_r((t+s)/2));
        }
        for (i = [0:11])
            cream_sample(tip_point(i/12),tip_point((i+1)/12),
                         tip_radius((i+0.5)/12));
        weight_metaball(0.5)
            translate(tip_point(1)) scale([0.425,0.425,0.425])
                sphere_metaball(r=0);
    }
}

union() {
    waffle_cone();
    soft_serve();
}
