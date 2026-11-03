//
//  MetalBezierDrawingTests.swift
//  MetalBezierDrawingTests
//
//  Created by radhika sharma on 11/2/26.
//

import Testing
import simd

@testable import MetalBezierDrawing

struct MetalBezierDrawingTests {
    private let tessellator = BezierTessellator()

    @Test func emptyStrokeHasNoGeometry() {
        let stroke = Stroke()
        #expect(tessellator.tessellate(stroke).isEmpty)
    }

    @Test func singleTapProducesVisibleGeometry() {
        var stroke = Stroke(width: 6)
        stroke.append(SIMD2(20, 30))
        let vertices = tessellator.tessellate(stroke)
        #expect(vertices.count == 4)
        #expect(vertices.allSatisfy { $0.x.isFinite && $0.y.isFinite })
    }

    @Test func straightStrokeProducesTriangleStrip() {
        var stroke = Stroke(width: 8)
        stroke.append(SIMD2(10, 10))
        stroke.append(SIMD2(100, 10))
        let vertices = tessellator.tessellate(stroke)
        #expect(vertices.count > 4)
        #expect(vertices.allSatisfy { $0.x.isFinite && $0.y.isFinite })
    }

    @Test func duplicateTouchSamplesAreIgnored() {
        var stroke = Stroke()
        stroke.append(SIMD2(10, 10))
        stroke.append(SIMD2(10, 10))
        #expect(stroke.points.count == 1)
    }

    @Test func curvedStrokeHasFiniteVertices() {
        var stroke = Stroke(width: 5)
        for point in [SIMD2<Float>(0, 0), SIMD2(20, 40),
                      SIMD2(40, 10), SIMD2(60, 60)] { stroke.append(point) }
        let vertices = tessellator.tessellate(stroke)
        #expect(vertices.count > 10)
        #expect(vertices.allSatisfy { $0.x.isFinite && $0.y.isFinite })
    }

    @Test func zeroWidthProducesNoGeometry() {
        var stroke = Stroke(width: 0)
        stroke.append(SIMD2(0, 0))
        #expect(tessellator.tessellate(stroke).isEmpty)
    }
}
