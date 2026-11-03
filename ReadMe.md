
# MetalBezierDrawing

A lightweight iOS drawing prototype built with **Swift, MetalKit, and quadratic Bézier curves** to explore touch-based drawing and GPU-accelerated stroke rendering.

## Features

- Freehand drawing using touch input
- Quadratic Bézier interpolation for smoother strokes
- Variable-width stroke geometry using triangle strips
- Multiple persistent strokes
- Rounded stroke caps
- Clear canvas functionality
- GPU rendering using Metal

## Architecture

The implementation separates touch input, stroke data, geometry generation, and rendering.

| Component | Responsibility |
|---|---|
| `ContentView` | SwiftUI interface and drawing controls |
| `DrawingView` | MetalKit view and touch event handling |
| `Stroke` | Stores stroke points, width, and color |
| `BezierTessellator` | Generates Bézier curve samples and triangle-strip geometry |
| `MetalRenderer` | Manages the Metal render pipeline, vertex buffers, and draw commands |
| `Shader.metal` | Vertex transformation and fragment coloring |

## Rendering Pipeline

1. **Touch input:** Collect touch samples in UIKit coordinates.
2. **Curve interpolation:** Generate quadratic Bézier segments using adjacent touch-point midpoints.
3. **Tessellation:** Calculate perpendicular offsets along the smoothed curve to generate triangle-strip vertices.
4. **GPU rendering:** Upload vertices to Metal buffers and render the resulting stroke geometry.
5. **Stroke persistence:** Cache completed stroke geometry while updating the active stroke during drawing.

## Design Decisions

**CPU-side tessellation:** Bézier interpolation and triangle generation are performed on the CPU to keep the initial implementation straightforward and independently testable.

**Triangle strips:** Used instead of Metal line primitives to support configurable stroke widths.

**Geometry caching:** Completed strokes retain their vertex buffers to avoid repeatedly tessellating unchanged geometry.

**Separation of responsibilities:** Stroke modeling and geometry generation are independent of the Metal rendering pipeline.

## Building and Running

1. Open `MetalBezierDrawing.xcodeproj` in Xcode.
2. Select an iOS Simulator or compatible device.
3. Build and run the application.
4. Draw using your finger or simulator pointer.
5. Use **Clear** to erase the canvas.

## Current Limitations and Future Improvements

This project is an exploratory rendering prototype rather than a production-ready drawing engine.

Potential improvements include:

- Incremental tessellation to avoid rebuilding the active stroke
- Adaptive Bézier subdivision based on curvature and segment length
- Improved joins and anti-aliasing
- Apple Pencil pressure and tilt support
- Undo and redo
- Render-to-texture caching for large drawings
- Performance profiling using Metal System Trace and Instruments

## Technologies

Swift · SwiftUI · UIKit · Metal · MetalKit · SIMD
