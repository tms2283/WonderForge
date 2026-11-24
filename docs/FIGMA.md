# Editable Figma system

The connected Figma document is:

https://www.figma.com/design/jKaRG95zeSfYndzreJxPGU

Open the page **REFORGED 0.3 · CINEMATIC SYSTEM**. It contains 13 full desktop frames: gateway plus 12 destinations including the Robot Logic Lab. The main layouts, labels, controls, icons, game grid, material tiles, and scenery overlays are made of editable text, rectangles, vector/polygon shapes and reusable instances; the world art is a **discrete image layer**, not a flattened raster of an entire interface.

Design variables: **Reforged / Semantic** has Starlight, Dawn and Contrast modes. **Reforged / Spacing** contains the consistent spacing scale. This is a starting design system, not a complete production-ready component library.

To make the art accessible in Figma, a separate scene was created with Figma's image generation feature; **this consumed Figma AI credits**. The local browser project contains its own original bundled environment image because this runtime could not reach Figma's asset-upload endpoint from the container. Expect artistic differences across the two sources. Use the browser prototype for behavioral truth and the Figma pages for editable visual exploration.

Import existing app changes back to Figma by updating the text and layout layers, not by covering the frames with screenshot images. For real native OS work, first resolve the Pi 4 test benchmarks and the user account model.
