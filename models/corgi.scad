// Pembroke Welsh corgi, standing naturally. Dimensions are millimetres.
// M3D SCAD: GPU (f32), Grid 280. A coarse torso loft feeds an SDF;
// the detailed final surface is sampled on the GPU.
// +Y faces forward. Paw soles are trimmed to the common Z=0 plane.

blend = 2.0;

module ellipsoid(p, r) {
    translate(p) scale(r) sphere(r=1);
}

// Compensate for the field outset: r is the intended surface size, not
// the smaller core radius. This avoids ballooning the muzzle and paws.
module organic(p, r, a=[0,0,0]) {
    k = min(r[0], min(r[1], r[2]));
    translate(p) rotate(a) scale([r[0]/k, r[1]/k, r[2]/k])
        sphere_metaball(r=k-blend);
}

module limb(a, b, r) {
    d = b-a;
    h = norm(d);
    translate(a) rotate(acos(d[2]/h), [-d[1],d[0],0])
        capsule_metaball(h=h, r=r-blend);
}

function torso_u(p) = (p[1]+8)/36;
function torso_inside(p) =
    pow(p[0]/(14.4+0.7*torso_u(p)),2) +
    pow((p[2]-(28.8-0.9*torso_u(p)))/(13.5+0.9*torso_u(p)),2) +
    pow(torso_u(p),6) <= 1;

module anatomy() {
    metaball_solid(blend, falloff="quartic") {
        // A long rib cage with a level topline and gently rounded flanks.
        metaball() mesh_to_sdf() dual_contour(delta=0.55)
            fn_solid([-16,-45,11], [16,29,45],
                     function(p) torso_inside(p));

        // Deep brisket, withers and an oblique neck, rather than a stack
        // of spherical neck and shoulder joints.
        organic([0,17,28], [13.5,12.5,18.5]);
        organic([0,22,40], [11.8,11.0,18.0], [-20,0,0]);
        organic([0,33,56], [11.3,10.5,10.0]);
        organic([0,36,50.5], [8.4,8.0,7.0]);

        // The nasal bridge slopes down into a tapered, foxlike muzzle.
        organic([0,40,53.4], [6.5,8.0,4.4], [-12,0,0]);
        translate([0,38.0,51.4]) rotate([-90,0,0])
            scale([1,0.65,1])
                cylinder_metaball(h=12.0, r1=5.7, r2=1.8);
        organic([0,43.8,47.8], [6.0,9.0,2.7]);

        for (s=[-1,1]) {

            // Forelegs descend from the chest into modest oval paws.
            organic([s*9.3,17,26], [6.0,8.0,12.5], [-9,0,0]);
            limb([s*10.0,20.0,17.0], [s*10.3,21.0,4.2], 3.9);
            organic([s*10.4,23.5,2.8], [4.8,6.3,3.7]);

            // Thigh, forward knee and rearward hock articulate each hind
            // leg. The lower leg is visibly narrower than the haunch.
            organic([s*10.8,-34,24], [8.3,11.0,14.0], [13,0,0]);
            organic([s*11.0,-27.5,14], [4.7,5.4,5.7]);
            limb([s*11.1,-28,13.5], [s*11.4,-38,5.5], 3.3);
            organic([s*11.4,-35.5,2.7], [4.4,5.8,3.6]);

            organic([s*8.5,29.7,59.0], [4.8,5.4,5.5]);

            // Tapered, convex ears lean outward and slightly backward.
            // Squashing only their depth gives rounded tips and a supple
            // cross-section, without flat triangular front/back plates.
            translate([s*7.4,30.0,58.0]) rotate([10,s*17,s*8]) scale([1,0.50,1])
                cylinder_metaball(h=13.5, r1=4.1, r2=0.65);
        }

        // A small bobtail, almost tucked into the rump's outline.
        organic([0,-44.2,33.5], [3.5,5.0,3.8], [24,0,0]);
    }
}

module details() {
    for (s=[-1,1]) {
        // Rounded conchal hollows leave a thick back and soft outer rim.
        translate([s*7.4,30.0,58.0]) rotate([10,s*17,s*8])
            ellipsoid([0,3.0,8.2], [2.65,3.15,5.3]);

        // Almond-shaped eye openings, small relative to the skull.
        translate([s*6.7,41.0,58.2]) rotate([0,0,-s*35])
            scale([2.05,1.0,1.25]) sphere(r=1);

        // Restrained toe separations, only at the fronts of the paws.
        for (dx=[-1.5,1.5]) {
            ellipsoid([s*10.4+dx,29.1,2.2], [0.48,1.8,1.7]);
            ellipsoid([s*11.4+dx,-30.4,2.0], [0.48,1.7,1.6]);
        }
    }

    // A thin closed lip line; the jaw stays joined across its broad root.
    ellipsoid([0,48.0,48.5], [8.1,7.8,0.38]);
}

module corgi() {
    union() {
        difference() {
            anatomy();
            details();
        }

        // Deep rear overlap anchors each eye to the head.
        for (s=[-1,1])
            translate([s*6.7,41.0,58.2]) rotate([0,0,-s*35])
                ellipsoid([0,-1.2,0], [1.50,1.50,0.90]);

        // A low, broad nose with small lateral nostril depressions.
        difference() {
            intersection() {
                ellipsoid([0,51.8,52.3], [4.3,1.85,2.6]);
                translate([0,52.4,52.3]) rotate([90,0,0])
                inset_extrude(height=3.0, center=true,
                              top=0.6, bottom=0.6,
                              top_fn="fillet", bottom_fn="fillet")
                    hull_sdf() {
                        translate([-2.8,0.5]) circle_hull(r=0.9);
                        translate([2.8,0.5]) circle_hull(r=0.9);
                        translate([0,-1.3]) circle_hull(r=0.85);
                    }
            }
            for (s=[-1,1])
                ellipsoid([s*2.1,53.55,52.5], [0.70,0.65,0.52]);
        }
    }
}

intersection() {
    corgi();
    translate([-50,-60,0]) cube([100,125,90]);
}
