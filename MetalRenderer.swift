//
//  MetalRenderer.swift
//  MetalBezierDrawing
//
//  Created by radhika sharma on 11/2/26.
//


import MetalKit

final class MetalRenderer: NSObject, MTKViewDelegate {
    
    private struct Geometry {
        let buffer: MTLBuffer
        let count: Int
        let color: SIMD4<Float>
    }

    private let device: MTLDevice
    private let queue: MTLCommandQueue
    private let pipeline: MTLRenderPipelineState
    private let tessellator = BezierTessellator()
    private var completed: [Geometry] = []
    private var active: Geometry?

    init(device: MTLDevice, view: MTKView) throws {
        self.device = device
        guard let queue = device.makeCommandQueue(),
              let library = device.makeDefaultLibrary(),
              let vertex = library.makeFunction(name: "vertexMain"),
              let fragment = library.makeFunction(name: "fragmentMain") else {
            throw RendererError.missingMetalResources
        }
        self.queue = queue
        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.vertexFunction = vertex
        descriptor.fragmentFunction = fragment
        descriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat
        self.pipeline = try device.makeRenderPipelineState(descriptor: descriptor)
        super.init()
    }

    private enum RendererError: Error { case missingMetalResources }

    func updateActiveStroke(_ stroke: Stroke) {
        let vertices = tessellator.tessellate(stroke)
        guard !vertices.isEmpty else { active = nil; return }
        let byteCount = vertices.count * MemoryLayout<SIMD2<Float>>.stride
        guard let buffer = device.makeBuffer(bytes: vertices, length: byteCount,
                                             options: .storageModeShared) else { return }
        active = Geometry(buffer: buffer, count: vertices.count, color: stroke.color)
    }
    
    func clear() {
        completed.removeAll()
        active = nil
    }

    func finishActiveStroke() {
        if let active { completed.append(active) }
        active = nil
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}

    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable,
              let pass = view.currentRenderPassDescriptor,
              let command = queue.makeCommandBuffer(),
              let encoder = command.makeRenderCommandEncoder(descriptor: pass) else { return }
        encoder.setRenderPipelineState(pipeline)
        var viewport = SIMD2<Float>(Float(view.bounds.width), Float(view.bounds.height))
        encoder.setVertexBytes(&viewport, length: MemoryLayout<SIMD2<Float>>.stride, index: 1)

        // Completed strokes retain their GPU buffers and need no retessellation.
        for geometry in completed { draw(geometry, with: encoder) }
        if let active { draw(active, with: encoder) }

        encoder.endEncoding()
        command.present(drawable)
        command.commit()
    }

    private func draw(_ geometry: Geometry, with encoder: MTLRenderCommandEncoder) {
        var color = geometry.color
        encoder.setVertexBuffer(geometry.buffer, offset: 0, index: 0)
        encoder.setFragmentBytes(&color, length: MemoryLayout<SIMD4<Float>>.stride, index: 0)
        encoder.drawPrimitives(type: .triangleStrip, vertexStart: 0,
                               vertexCount: geometry.count)
    }
}
