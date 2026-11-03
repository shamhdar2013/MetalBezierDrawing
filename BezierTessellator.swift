//
//  BezierTesseilator.swift
//  MetalBezierDrawing
//
//  Created by radhika sharma on 11/2/26.
//

import Foundation

import simd

struct BezierTessellator {
    let samplesPerSegment: Int

    init(samplesPerSegment: Int = 12) {
        self.samplesPerSegment = max(1, samplesPerSegment)
    }

    func tessellate(_ stroke: Stroke) -> [SIMD2<Float>] {
        guard stroke.width > 0, !stroke.points.isEmpty else { return [] }
        let points = curvePoints(stroke.points)
        let radius = stroke.width * 0.5

        // A tap is rendered as a small quad; longer strokes get round caps.
        if points.count == 1 {
            let p = points[0]
            return [p + SIMD2(-radius, -radius),
                    p + SIMD2(radius, -radius),
                    p + SIMD2(-radius, radius),
                    p + SIMD2(radius, radius)]
        }

        var strip: [SIMD2<Float>] = []
        strip.reserveCapacity((points.count + 18) * 2)
        let firstDirection = simd_normalize(points[1] - points[0])
        let lastDirection = simd_normalize(points[points.count - 1] - points[points.count - 2])

        // The strip starts and ends at the stroke center; fan-like pairs
        // approximate semicircular caps without requiring another draw call.
        appendCap(center: points[0], direction: -firstDirection,
                  radius: radius, starting: true, into: &strip)

        for i in points.indices {
            let before = points[max(i - 1, 0)]
            let after = points[min(i + 1, points.count - 1)]
            let tangent = after - before
            let length = simd_length(tangent)
            guard length > 0.0001 else { continue }
            let normal = SIMD2<Float>(-tangent.y, tangent.x) / length
            strip.append(points[i] + normal * radius)
            strip.append(points[i] - normal * radius)
        }
        appendCap(center: points[points.count - 1], direction: lastDirection,
                  radius: radius, starting: false, into: &strip)
        return strip
    }

    private func appendCap(center: SIMD2<Float>, direction: SIMD2<Float>,
                           radius: Float, starting: Bool,
                           into vertices: inout [SIMD2<Float>]) {
        // Degenerate strip pairs at the cap center connect the cap to the body.
        let normal = SIMD2<Float>(-direction.y, direction.x)
        let steps = 8
        if starting {
            for i in 0...steps {
                let theta = Float.pi * Float(i) / Float(steps)
                let point = center + (direction * sin(theta) - normal * cos(theta)) * radius
                vertices.append(center)
                vertices.append(point)
            }
            vertices.append(center)
            vertices.append(center)
        } else {
            vertices.append(center)
            vertices.append(center)
            for i in 0...steps {
                let theta = Float.pi * Float(i) / Float(steps)
                let point = center + (direction * sin(theta) + normal * cos(theta)) * radius
                vertices.append(point)
                vertices.append(center)
            }
        }
    }

    private func curvePoints(_ raw: [SIMD2<Float>]) -> [SIMD2<Float>] {
        var input: [SIMD2<Float>] = []
        for p in raw where p.x.isFinite && p.y.isFinite {
            if let last = input.last, simd_distance_squared(last, p) < 0.0001 { continue }
            input.append(p)
        }
        guard input.count > 2 else { return input }
        var output: [SIMD2<Float>] = [input[0]]
        for i in 1..<(input.count - 1) {
            let start = (input[i - 1] + input[i]) * 0.5
            let end = (input[i] + input[i + 1]) * 0.5
            let control = input[i]
            // Skip t=0: the previous segment already ends there.
            for step in 0...samplesPerSegment {
                let t = Float(step) / Float(samplesPerSegment)
                let u = 1 - t
                let p = u*u*start + 2*u*t*control + t*t*end
                if let last = output.last, simd_distance_squared(last, p) < 0.0001 { continue }
                output.append(p)
            }
        }
        if let last = output.last, simd_distance_squared(last, input[input.count - 1]) >= 0.0001 {
            output.append(input[input.count - 1])
        }
        return output
    }
}
