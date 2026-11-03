//
//  ContentView.swift
//  MetalBezierDrawing
//
//  Created by radhika sharma on 11/2/26.
//

import SwiftUI
import MetalKit

struct ContentView: View {
    @State private var clearID = UUID()

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Start Drawing")
                    .font(.title2)
                Spacer()
                Button("Clear", role: .destructive) {
                    clearID = UUID()
                }
                .buttonStyle(.bordered)
                .accessibilityLabel("Clear drawing")
            }
            .padding()

            MetalDrawingView(clearID: clearID)
        }
    }
}

struct MetalDrawingView: UIViewRepresentable {
    let clearID: UUID

    final class Coordinator {
        var lastClearID: UUID?
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> DrawingView {
        context.coordinator.lastClearID = clearID
        return DrawingView(frame: .zero)
    }

    func updateUIView(_ uiView: DrawingView, context: Context) {
        guard context.coordinator.lastClearID != clearID else { return }
        context.coordinator.lastClearID = clearID
        uiView.clear()
    }
}

