# m3dscad-codex

Use app.m3dscad.com to build a 3D model. Make it compile on GPU at <=300 grid size. Compilation might take a little while, but just aim for <= 1 minute.
Use m3dscad.com for documentation.

When the model is built, pan around the rendering to check for defects on all sides of it. Try to make resulting objects look natural, without unusual creases or seams that wouldn't be found in a real object. Avoid tiny thin parts of the object, since dual contouring might miss those.

Store your final code in the models/ directory with an appropriate name.

Note that `fn_solid` doesn't allow GPU acceleration, so it should generally be avoided when possible, or be used to produce low-resolution meshes that are then converted to solids/SDFs for the remaining expensive render.

Don't use Blender or other software to style or render the model. Only use renderings directly from the m3dscad webui. Only save .scad files to this repository in the models/ directory; no other scripts or information.

When done, show not only the final scad code, but also a screenshot of the m3dscad.

# Advice from past examples

Prefer GPU-compatible primitives and smooth blends; for custom organic surfaces, deform a moderately detailed mesh and convert it with mesh_to_sdf() before final GPU compilation. Make small features large enough to resolve at the target grid size, and favor continuous surface shaping over dense collections of tiny overlapping parts or cuts. Test a representative detailed section first, checking compilation time and viewing it from oblique angles before repeating that technique across the whole model.

Build the silhouette and proportions first, then add details; gentle asymmetry and smooth transitions often contribute more realism than tiny surface features. Keep deformation formulas smooth across joins, and remember that increasing the final grid resolution won’t remove faceting already present in the source mesh. Size small features relative to the overall model and inspect top, bottom, and oblique views early—one flattering camera angle can hide defects.

Prototype the most detailed section first, and check the browser console to confirm GPU execution—selecting GPU can still allow a CPU fallback. Keep geometry complexity modest: hundreds of transformed primitives can compile slowly, while large metaball sums can exceed shader limits. For organic shapes built along a path, weight metaball samples by their spacing and tune the blend strength to preserve recognizable details without visible seams. Inspect oblique views and the underside, then check the exported mesh for disconnected pieces, tiny enclosed cavities, and non-manifold edges.

Block out the silhouette with a few large, GPU-compatible forms, and inspect all sides before adding detail. Metaball scaling affects both shape and blending, so tune primitive size and blend strength together to avoid swollen joints or pinched seams. Place grooves and surface details against the actual blended surface, rather than estimating their positions from the original primitives, and make important features span several grid cells. Test one representative detailed section at the intended final grid size before repeating it across the model, checking both appearance and compilation time.