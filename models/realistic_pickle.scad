// Upright, plump dill pickle with a pronounced bend and restrained skin texture.
// M3D-SCAD: GPU (f32), Grid 280. Dimensions are in millimetres.
// All geometry uses GPU-supported primitives and smooth metaball blending.

bend_radius = 76;
bend_angle = 84;
thickness = 1.30;
body_samples = 44;
skin_bumps = 60;
skin_weight = 0.60;

function hash(n) = abs(sin(n*127.1+311.7)*43758.5453)
                 -floor(abs(sin(n*127.1+311.7)*43758.5453));
function angle(t) = bend_angle*(t-0.5);
function center(t) = [bend_radius*(1-cos(angle(t))),
                       0.45*sin(240*t),bend_radius*sin(angle(t))];
function radius(t) = thickness*(11.5+2.7*sin(180*t)-0.7*t);
function tangent(t) = [sin(angle(t)),0,cos(angle(t))];
function radial(t,a) = [cos(angle(t))*cos(a),sin(a),-sin(angle(t))*cos(a)];

// Tangent conical envelopes keep the curved body free of scalloped joins.
module body_link(p,q,r0,r1) {
    v = q-p;
    d = norm(v);
    k = (r0-r1)/d;
    c = sqrt(1-k*k);
    translate(p) sphere_sdf(r=r0);
    translate(p+v*(k*r0/d))
        rotate(a=acos(v[2]/d),v=[-v[1],v[0],0])
            cylinder_sdf(h=d-k*(r0-r1),r1=r0*c,r2=r1*c);
}

module flesh() {
    metaball() union() {
        for (i=[0:body_samples-1])
            body_link(center(i/body_samples),center((i+1)/body_samples),
                      radius(i/body_samples),radius((i+1)/body_samples));
        translate(center(1)) sphere_sdf(r=radius(1));
    }
}

// Small, low-relief bumps follow cross-sections perpendicular to the bend.
// Reduced weights and deeper embedding keep the silhouette mostly smooth.
module skin() {
    weight_metaball(skin_weight)
        for (i=[0:skin_bumps-1]) {
            t = 0.015+0.97*(i+0.2+0.6*hash(i+39))/skin_bumps;
            a = i*137.50776+42*hash(i+65);
            r = 1.25+0.7*hash(i+12);
            h = -0.05+0.35*hash(i+97);
            translate(center(t)+radial(t,a)*(radius(t)-r+h))
                rotate([0,angle(t),0])
                    scale([1,1,1.05+0.2*hash(i+13)])
                        sphere_metaball(r=r);
        }

    // Sparse, softer texture continues onto the rounded end caps.
    weight_metaball(0.24)
        for (end=[0,1])
            for (i=[0:5]) {
                a = i*137.50776+end*71;
                p = 28+30*hash(i+end*37);
                n = radial(end,a)*cos(p)
                    +tangent(end)*(2*end-1)*sin(p);
                translate(center(end)+n*(radius(end)-1.6))
                    sphere_metaball(r=1.4);
            }
}

module pickle() {
    difference() {
        metaball_solid(1,falloff="exponential") {
            flesh();
            skin();

            // A sturdy stem nub follows the tangent of the curved shoulder.
            translate(center(1)+tangent(1)*(radius(1)-0.8))
                rotate([0,angle(1)+8,0])
                    capsule_metaball(h=3.0,r=1.8);
        }

        // Shallow blossom scar, aligned with the other rounded pole.
        translate(center(0)-tangent(0)*(radius(0)+0.7))
            rotate([0,angle(0),0])
                scale([1,0.85,0.52]) sphere(r=2.2);
    }
}

// Stand along Z with the rounded blossom end near the ground plane.
translate([0,0,bend_radius*sin(bend_angle/2)+radius(0)+0.3]) pickle();
