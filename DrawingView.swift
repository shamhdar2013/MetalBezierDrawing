//
//  DrawingView.swift
//  MetalBezierDrawing
//
//  Created by radhika sharma on 11/2/26.
//

import UIKit
import MetalKit

final class DrawingView: MTKView {

    private var renderer: MetalRenderer!
    private var activeStroke: Stroke?
    private weak var trackedTouch: UITouch?

    required init(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    override init(frame: CGRect, device: MTLDevice?) {
        super.init(frame: frame, device: device)
        setup()
    }

    private func setup() {
        guard let gpu = MTLCreateSystemDefaultDevice() else {
            fatalError("Metal is required for this sample")
        }
        device = gpu
        colorPixelFormat = .bgra8Unorm
        clearColor = MTLClearColor(red: 0.2, green: 0.6, blue: 0.2, alpha: 1)
        isPaused = true
        enableSetNeedsDisplay = true
        isMultipleTouchEnabled = false
        do {
            renderer = try MetalRenderer(device: gpu, view: self)
        } catch {
            fatalError("Unable to configure Metal renderer: \(error)")
        }
        delegate = renderer
    }

    private func append(_ touch: UITouch) {
        guard var stroke = activeStroke else { return }
        let location = touch.location(in: self)
        let count = stroke.points.count
        stroke.append(SIMD2(Float(location.x), Float(location.y)))
        guard stroke.points.count != count else { return }
        activeStroke = stroke
        renderer.updateActiveStroke(stroke)
        setNeedsDisplay()
    }
    
    func clear() {
        activeStroke = nil
        trackedTouch = nil
        renderer.clear()
        setNeedsDisplay()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard trackedTouch == nil, let touch = touches.first else { return }
        trackedTouch = touch
        activeStroke = Stroke(width: 5)
        append(touch)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = trackedTouch, touches.contains(touch) else { return }
        for sample in event?.coalescedTouches(for: touch) ?? [touch] {
            append(sample)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = trackedTouch, touches.contains(touch) else { return }
        append(touch)
        finishStroke()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = trackedTouch, touches.contains(touch) else { return }
        // Preserve samples already collected even if the system interrupts input.
        finishStroke()
    }

    private func finishStroke() {
        if activeStroke != nil { renderer.finishActiveStroke() }
        activeStroke = nil
        trackedTouch = nil
        setNeedsDisplay()
    }
}


