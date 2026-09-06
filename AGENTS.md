# m3dscad-codex

Use app.m3dscad.com to build a 3D model. Make it compile on GPU at <=300 grid size. Compilation might take a little while, but just aim for <= 1 minute.
Use m3dscad.com for documentation.

When the model is build, pan around the rendering to check for defects on all sides of it. Try to make resulting objects look natural, without unusual creases or seams that wouldn't be found in a real object. Avoid tiny thin parts of the object, since dual contouring might miss those.

Store your final code in the models/ directory with an appropriate name.

Note that fn_solid doesn't allow GPU acceleration, so it should generally be avoided when possible, or be used to produce low-resolution meshes that are then converted to solids/SDFs for the remaining expensive render.

Don't use Blender or other software to style or render the model. Only use renderings directly from the m3dscad webui.

When done, show not only the final scad code, but also a screenshot of the m3dscad.
