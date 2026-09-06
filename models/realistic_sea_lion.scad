// California sea lion, resting with its head raised.
// Millimetres; nose faces -Y, Z is up. GPU (f32), grid 280.
// Smooth organic fields and gently curved, solid flippers. No fn_solid.

module flesh(p,r,a=[0,0,0]) {
    translate(p) rotate(a) scale(r/1.42) sphere_metaball(1);
}
module ellipsoid(p,r,a=[0,0,0]) {
    translate(p) rotate(a) scale(r) sphere(1);
}
function unit(p)=p/norm(p);
function bezier(a,b,c,t)=a*(1-t)*(1-t)+b*2*t*(1-t)+c*t*t;

// One C2-continuous loft runs from the rump through the neck to the nose.
// Columns: centre Y, centre Z, transverse and sagittal radius factors.
spine=[
    [70,7,12,8], [53,13,14.167,11.667], [32,22,25,21.25],
    [8,25,24,22.4], [-10,34,19.4,18.4], [-22,49,14,15],
    [-30,64,11.7,13.3], [-37,76,13.1,11.5],
    [-47,76,11.3,8.5], [-57,73.5,10,7.5], [-64,73.5,12,6]
];
function node(i)=i<0 ? 2*spine[0]-spine[1] :
    (i>10 ? 2*spine[10]-spine[9] : spine[i]);
function spline_part(i,t)=
    (node(i-1)*pow(1-t,3)
    +node(i)*(3*t*t*t-6*t*t+4)
    +node(i+1)*(-3*t*t*t+3*t*t+3*t+1)
    +node(i+2)*t*t*t)/6;
function spline(t)=spline_part(min(9,floor(t*10)),t*10-min(9,floor(t*10)));
function skin_point(p)=skin_unit(unit(p));
function skin_unit(p)=skin_frame(p,(p[1]+1)/2);
function skin_frame(p,t)=skin_shape(p,spline(t),
    spline(min(1,t+0.001))-spline(max(0,t-0.001)));
function skin_shape(p,c,d)=[
    p[0]*c[2],
    c[0]+p[2]*c[3]*d[1]/sqrt(d[0]*d[0]+d[1]*d[1]),
    c[1]-p[2]*c[3]*d[0]/sqrt(d[0]*d[0]+d[1]*d[1])
];
module body_skin() {
    metaball() mesh_to_sdf()
        transform(function(p) skin_point(p))
            dual_contour(delta=0.035) sphere(1);
}

// A curved paddle with a thicker shoulder and a softly rounded tip.
// Small seed meshes are converted to SDFs for the final GPU contour.
function fore_point(p,s)=fore_param(unit(p),s);
function fore_param(p,s)=fore_shape(p,s,(p[1]+1)/2);
function fore_shape(p,s,t)=[
    s*(12+(s<0 ? 29 : 32)*t+3*sin(180*t)+0.8*p[0]*(7+4*t)),
    -18+(s<0 ? 39 : 34)*t-0.6*p[0]*(7+4*t),
    3.1+29*pow(1-t,3)+p[2]*(3.2+2.3*pow(1-t,2))
];
function rear_point(p,s)=rear_param(unit(p),s);
function rear_param(p,s)=rear_shape(p,s,(p[1]+1)/2);
function rear_shape(p,s,t)=[
    s*(4+13*t+p[0]*(5.2+3.1*t)),
    54+33*t-sin(180*t)*2,
    3.3+3*pow(1-t,2)+p[2]*(2.0+1.2*(1-t))
];
module fore_flipper(s) {
    metaball() mesh_to_sdf()
        transform(function(p) fore_point(p,s))
            dual_contour(delta=0.12) sphere(1);
}
module rear_flipper(s) {
    metaball() mesh_to_sdf()
        transform(function(p) rear_point(p,s))
            dual_contour(delta=0.12) sphere(1);
}

module anatomy() {
    metaball_solid(0.42,falloff="quartic") {
        body_skin();
        for(s=[-1,1]) {
            flesh([s*3.5,-58,72.9],[3.8,5.0,3.1]);
            // Small swept-back external ear flaps.
            flesh([s*9.8,-31.5,76.6],[2.1,3.8,2.0],[0,s*12,s*12]);
            flesh([s*10.6,-29.1,77.0],[1.1,2.0,1.4],[0,s*12,s*12]);
            // The foreflipper root begins well inside the shoulder.
            fore_flipper(s);
            rear_flipper(s);
        }
        // Short tail between the paired rear flippers.
        flesh([0,68,5.4],[3.1,9.0,2.5]);
    }
}

// Shallow digit channels follow the upper hind-flipper surface.
module flipper_detail() {
    for(s=[-1,1]) {
        line_join([
            [s*11.250,75.800,6.139],
            [s*11.404,76.415,6.051],
            [s*11.558,77.031,5.961],
            [s*11.712,77.646,5.870],
            [s*11.865,78.262,5.779],
            [s*12.019,78.877,5.683],
            [s*12.173,79.492,5.589],
            [s*12.327,80.108,5.489],
            [s*12.481,80.723,5.385],
            [s*12.635,81.338,5.278],
            [s*12.788,81.954,5.168],
            [s*12.942,82.569,5.050],
            [s*13.096,83.185,4.926],
            [s*13.250,83.800,4.793]
        ],r=0.60);
        line_join([
            [s*13.750,76.600,6.122],
            [s*13.904,77.215,6.038],
            [s*14.058,77.831,5.951],
            [s*14.212,78.446,5.864],
            [s*14.365,79.062,5.780],
            [s*14.519,79.677,5.687],
            [s*14.673,80.292,5.594],
            [s*14.827,80.908,5.502],
            [s*14.981,81.523,5.404],
            [s*15.135,82.138,5.304],
            [s*15.288,82.754,5.200],
            [s*15.442,83.369,5.087],
            [s*15.596,83.985,4.973],
            [s*15.750,84.600,4.846]
        ],r=0.60);
        line_join([
            [s*16.250,76.600,5.938],
            [s*16.404,77.215,5.861],
            [s*16.558,77.831,5.783],
            [s*16.712,78.446,5.700],
            [s*16.865,79.062,5.620],
            [s*17.019,79.677,5.535],
            [s*17.173,80.292,5.449],
            [s*17.327,80.908,5.361],
            [s*17.481,81.523,5.264],
            [s*17.635,82.138,5.168],
            [s*17.788,82.754,5.069],
            [s*17.942,83.369,4.957],
            [s*18.096,83.985,4.832],
            [s*18.250,84.600,4.702]
        ],r=0.60);
        line_join([
            [s*18.750,75.800,5.339],
            [s*18.904,76.415,5.286],
            [s*19.058,77.031,5.211],
            [s*19.212,77.646,5.147],
            [s*19.365,78.262,5.076],
            [s*19.519,78.877,4.998],
            [s*19.673,79.492,4.904],
            [s*19.827,80.108,4.811],
            [s*19.981,80.723,4.718],
            [s*20.135,81.338,4.587],
            [s*20.288,81.954,4.458],
            [s*20.442,82.569,4.306],
            [s*20.596,83.185,4.075],
            [s*20.750,83.800,3.764]
        ],r=0.60);
    }
}

module face_cuts() {
    for(s=[-1,1]) {
        // Almond sockets angle forward and out from the skull.
        ellipsoid([s*10.20,-45.05,77.05],[1.30,2.70,1.75],[0,-s*15,-s*16]);
        // Shallow ear concha with a generous rim.
        ellipsoid([s*11.6,-30.9,77.2],[0.75,1.75,0.80],[0,0,s*12]);
    }
    // A shallow closed lip follows the measured muzzle surface.
    line_join([
        [-8.617,-46.000,72.100],
        [-8.399,-46.451,72.009],
        [-8.206,-46.903,71.920],
        [-8.015,-47.354,71.831],
        [-7.822,-47.805,71.744],
        [-7.635,-48.257,71.660],
        [-7.456,-48.708,71.580],
        [-7.287,-49.159,71.503],
        [-7.129,-49.611,71.431],
        [-6.967,-50.062,71.363],
        [-6.809,-50.514,71.301],
        [-6.669,-50.965,71.245],
        [-6.533,-51.416,71.196],
        [-6.403,-51.868,71.153],
        [-6.287,-52.319,71.117],
        [-6.177,-52.770,71.089],
        [-6.076,-53.222,71.068],
        [-5.986,-53.673,71.055],
        [-5.906,-54.124,71.050],
        [-5.851,-54.576,71.052],
        [-5.859,-55.027,71.063],
        [-5.973,-55.478,71.081],
        [-6.196,-55.930,71.108],
        [-6.385,-56.381,71.141],
        [-6.541,-56.832,71.183],
        [-6.666,-57.284,71.231],
        [-6.750,-57.735,71.286],
        [-6.794,-58.186,71.347],
        [-6.805,-58.638,71.415],
        [-6.783,-59.089,71.487],
        [-6.727,-59.541,71.565],
        [-6.631,-59.992,71.647],
        [-6.502,-60.443,71.733],
        [-6.315,-60.895,71.823],
        [-6.072,-61.346,71.915],
        [-5.723,-61.797,72.009],
        [-5.257,-62.249,72.104],
        [-4.493,-62.700,72.200],
        [0.000,-63.660,72.250],
        [4.493,-62.700,72.200],
        [5.257,-62.249,72.104],
        [5.723,-61.797,72.009],
        [6.072,-61.346,71.915],
        [6.315,-60.895,71.823],
        [6.502,-60.443,71.733],
        [6.631,-59.992,71.647],
        [6.727,-59.541,71.565],
        [6.783,-59.089,71.487],
        [6.805,-58.638,71.415],
        [6.794,-58.186,71.347],
        [6.750,-57.735,71.286],
        [6.666,-57.284,71.231],
        [6.541,-56.832,71.183],
        [6.385,-56.381,71.141],
        [6.196,-55.930,71.108],
        [5.973,-55.478,71.081],
        [5.859,-55.027,71.063],
        [5.851,-54.576,71.052],
        [5.906,-54.124,71.050],
        [5.986,-53.673,71.055],
        [6.076,-53.222,71.068],
        [6.177,-52.770,71.089],
        [6.287,-52.319,71.117],
        [6.403,-51.868,71.153],
        [6.533,-51.416,71.196],
        [6.669,-50.965,71.245],
        [6.809,-50.514,71.301],
        [6.967,-50.062,71.363],
        [7.129,-49.611,71.431],
        [7.287,-49.159,71.503],
        [7.456,-48.708,71.580],
        [7.635,-48.257,71.660],
        [7.822,-47.805,71.744],
        [8.015,-47.354,71.831],
        [8.206,-46.903,71.920],
        [8.399,-46.451,72.009],
        [8.617,-46.000,72.100]
    ],r=0.48);
}

// Short, curved vibrissae have a 1.4 mm diameter throughout.
// They are rooted inside the whisker pads, with no floating fragments.
module whiskers() {
    for(s=[-1,1]) {
        for(j=[0:2]) {
            a=[s*6.55,-55.8-2.1*j,73.9-0.55*j];
            b=[s*(12.3+0.8*j),-55.0-3.0*j,74.3-1.0*j];
            c=[s*(17.0+1.3*j),-56.3-3.4*j,73.6-1.4*j];
            line_join([for(i=[0:10]) bezier(a,b,c,i/10)],r=0.70);
        }
    }
}

module face_details() {
    for(s=[-1,1]) {
        ellipsoid([s*9.34,-44.80,76.82],[1.45,2.15,1.20],[0,-s*15,-s*16]);
    }
    difference() {
        // Broad, slightly triangular rhinarium rather than a ball nose.
        ellipsoid([0,-63.0,73.7],[4.55,2.55,2.65],[-8,0,0]);
        for(s=[-1,1])
            ellipsoid([s*2.1,-65.1,74.3],[0.95,0.90,0.66],[0,s*15,s*20]);
        line_join([[0,-65.4,72.0],[0,-65.5,73.1]],r=0.4);
    }
}

union() {
    difference() { anatomy(); face_cuts(); flipper_detail(); }
    face_details();
    whiskers();
}
