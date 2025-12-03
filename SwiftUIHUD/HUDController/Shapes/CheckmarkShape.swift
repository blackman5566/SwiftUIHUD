//
//  CheckmarkShape.swift
//  SwiftUIHUD
//
//  Created by Allen Shu on 2025/12/3.
//

import SwiftUI

/// A checkmark drawing shape.
///
/// The shape draws in two segments:
/// 1. From the lower-left point to the middle point.
/// 2. From the middle point to the upper-right point.
///
/// The `progress` value (0...1) controls how much of the checkmark
/// has been drawn, allowing smooth stroke animations.
public struct CheckmarkShape: Shape {

    /// Drawing progress (0...1).
    /// Controls how much of the checkmark path is visible.
    public var progress: CGFloat

    /// Required for animation purposes — makes `progress` animatable.
    public var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    public init(progress: CGFloat = 1.0) {
        self.progress = progress
    }

    public func path(in rect: CGRect) -> Path {
        var path = Path()

        let w = rect.width
        let h = rect.height

        // Key points of the checkmark
        let p1 = CGPoint(x: w * 0.25, y: h * 0.5)   // lower-left
        let p2 = CGPoint(x: w * 0.5,  y: h * 0.75)  // middle
        let p3 = CGPoint(x: w * 0.85, y: h * 0.25)  // upper-right

        // Distances between segments
        let d12 = distance(from: p1, to: p2)
        let d23 = distance(from: p2, to: p3)
        let total = d12 + d23

        // Clamp progress to 0...1 and convert to path distance
        let current = max(0, min(progress, 1)) * total

        path.move(to: p1)

        if current <= d12 {
            // Drawing the first segment (p1 -> p2)
            let t = d12 == 0 ? 0 : current / d12
            let mid = interpolate(from: p1, to: p2, t: t)
            path.addLine(to: mid)
        } else {
            // First segment completed, draw second segment (p2 -> p3)
            path.addLine(to: p2)
            let extra = current - d12
            let t = d23 == 0 ? 0 : min(1, extra / d23)
            let mid = interpolate(from: p2, to: p3, t: t)
            path.addLine(to: mid)
        }

        return path
    }

    // MARK: - Helpers

    private func distance(from a: CGPoint, to b: CGPoint) -> CGFloat {
        hypot(a.x - b.x, a.y - b.y)
    }

    private func interpolate(from a: CGPoint, to b: CGPoint, t: CGFloat) -> CGPoint {
        CGPoint(
            x: a.x + (b.x - a.x) * t,
            y: a.y + (b.y - a.y) * t
        )
    }
}
