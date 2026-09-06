// Organic human brain study. Dimensions in millimetres.
// app.m3dscad.com: GPU (f32), grid 280.
// A deformed seed mesh carries the cortical folds; mesh_to_sdf makes
// the final contour GPU compatible. No fn_solid is used.

surface_sampling = 0.018;
fold_depth = 6.0;

function sq(x) = x*x;
function unit(p) = p/norm(p);
function groove(x) = exp(-sq(x));

// Smoothly warped intersecting waves create branching sulci, without
// longitude seams or a pinched pole. The two sides differ subtly.
function cortex_field(x,y,z) =
    sin(18*x + 95*sin(5.8*y) + 34*sin(8*z))
  + sin(17*y + 78*sin(6.5*z) + 39*cos(7.1*x))
  + 0.72*sin(20*z + 80*sin(6.2*x) + 31*cos(6*y));
function fold(x,y,z) = fold_depth/(1+sq(cortex_field(x,y,z)/0.70));
function fissure(x,z) = 14*groove(x/2.35)*(0.2+0.8/(1+exp(-(z-64)/6)));
function lateral(x,y,z) = 3.2*groove((z-65-0.20*y-3*sin(3*y))/2.7)
    /(1+exp(-(abs(x)-42)/3))/(1+exp((y-30)/5));
function relief(x,y,z) = fold(x,y,z)+fissure(x,z)+lateral(x,y,z)
    +0.7*sin(4*y+3*z)*cos(4*x);
function cerebrum_point(p) = cortical_point(unit(p));
function cortical_point(p) = cerebral_xyz(p,66*p[0],82*p[1],79+53*p[2]);
function cerebral_xyz(p,x,y,z) = cerebral_displace(p,x,y,z,relief(x,y,z));
function cerebral_displace(p,x,y,z,d) = [
    x*(1+0.035*sin(2*y))-d*p[0],
    y-d*p[1],
    z-d*p[2]+1.5*sin(2*y)*sq(p[0])
];

module cerebrum() {
    solid() mesh_to_sdf()
        transform(function(p) cerebrum_point(p))
            dual_contour(delta=surface_sampling) sphere(1);
}

// The cerebellum has finer, predominantly transverse folia, and a
// shallow midline notch. It tucks into the back of the cerebral mass.
function cerebellum_point(p) = cerebellum_unit(unit(p));
function cerebellum_unit(p) = cerebellum_xyz(p,44*p[0],32*p[1],24*p[2]);
function cerebellum_xyz(p,x,y,z) = cerebellum_displace(p,x,y,z,
    1.4*groove(sin(36*z+23*sin(4*x)+13*sin(5*y))/0.62)
    +2.6*groove(x/4));
function cerebellum_displace(p,x,y,z,d) = [
    x-d*p[0], 43+y-d*p[1], 31+z-d*p[2]
];

module cerebellum() {
    solid() mesh_to_sdf()
        transform(function(p) cerebellum_point(p))
            dual_contour(delta=0.025) sphere(1);
}

// Broad pons and a short tapered medulla. Deep overlaps keep the
// underside connected and avoid fragile projecting nerves.
module brainstem() {
    metaball_solid(1,falloff="exponential") {
        translate([0,10,29]) scale([13,15,17]) sphere_metaball(1);
        translate([0,16,15]) rotate([-16,0,0])
            capsule_metaball(h=17,r=7.5,center=true);
        translate([0,12,5]) scale([7,7.8,5]) sphere_metaball(1);
    }
}

union() {
    cerebrum();
    cerebellum();
    brainstem();
}
