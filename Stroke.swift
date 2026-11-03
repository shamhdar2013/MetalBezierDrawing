//
//  Stroke.swift
//  MetalBezierDrawing
//
//  Created by radhika sharma on 11/2/26.
//
import Foundation
import simd

struct Stroke {
    let id: UUID
    var points: [SIMD2<Float>]
    var width: Float
    var color: SIMD4<Float>

    init(
        width: Float = 6.0,
        color: SIMD4<Float> = SIMD4<Float>(0, 0, 1, 1)
    ) {
        self.id = UUID()
        self.points = []
        self.width = width
        self.color = color
    }

    mutating func append(_ point: SIMD2<Float>) {
        guard points.last != point else { return }
        points.append(point)
    }
}
