# m3dscad-codex

A collection of 3D models built with Codex for [m3dscad](https://m3dscad.com/). The models explore organic shapes, smooth surfaces, and details using metaballs, signed distance fields, and sculpted meshes.

## Models

Each model has editable `.scad` source in [`models/`](models/). Dimensions are in millimetres.

| Model | Source |
| --- | --- |
| Pembroke Welsh corgi | [SCAD](models/corgi.scad) |
| Flat-bottom soft-serve cone | [SCAD](models/flat_bottom_soft_serve.scad) |
| Human brain | [SCAD](models/realistic_brain.scad) |
| Dill pickle | [SCAD](models/realistic_pickle.scad) |
| Pond frog | [SCAD](models/realistic_pond_frog.scad) |
| Field pumpkin | [SCAD](models/realistic_pumpkin.scad) |
| California sea lion | [SCAD](models/realistic_sea_lion.scad) |
| Trout | [SCAD](models/realistic_trout.scad) |

## Render a model

1. Open the [m3dscad web editor](https://app.m3dscad.com/).
2. Copy a model's `.scad` source into the editor.
3. Select **GPU (f32)** and set **Grid** to **280**, as specified in the model headers.
4. Compile, then rotate the view to inspect the model from all sides.

The files use m3dscad-specific primitives. See [m3dscad](https://m3dscad.com/) for documentation and language examples.

## Modeling guidelines

Keep the final render compatible with GPU compilation at a grid size of **300 or less**, aiming for compilation within one minute. Favor natural surfaces and substantial details that survive dual contouring. Inspect every side for unintended seams, creases, and missing geometry using the m3dscad web editor.

See [`AGENTS.md`](AGENTS.md) for the full modeling instructions. Save model source in `models/`; rendered images are excluded from the repository.
