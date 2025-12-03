//
//  CrossShape.swift
//  SwiftUIHUD
//
//  Created by Allen Shu on 2025/12/3.
//

import SwiftUI

/// A drawable "X" shape that supports animated stroke drawing.
///
/// The `progress` value (0...1) controls how much of the shape is drawn:
/// - 0.0 → no lines drawn
/// - 1.0 → full X completed
///
/// This is typically used with animations:
///
/// ```swift
/// CrossShape(progress: animatedValue)
///     .stroke(Color.red, lineWidth: 3)
///     .animation(.linear(duration: 0.6), value: animatedValue)
/// ```
public struct CrossShape: Shape {

    /// Drawing progress (0...1)
    public var progress: CGFloat

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

        // First diagonal: top-left → bottom-right
        let a1 = CGPoint(x: w * 0.15, y: h * 0.15)
        let a2 = CGPoint(x: w * 0.85, y: h * 0.85)

        // Second diagonal: top-right → bottom-left
        let b1 = CGPoint(x: w * 0.85, y: h * 0.15)
        let b2 = CGPoint(x: w * 0.15, y: h * 0.85)

        let d1 = distance(from: a1, to: a2)
        let d2 = distance(from: b1, to: b2)
        let total = d1 + d2

        // Clamp progress between 0 and 1
        let current = max(0, min(progress, 1)) * total

        // ---- First stroke segment ----
        path.move(to: a1)

        if current <= d1 {
            // Still drawing the first line
            let t = d1 == 0 ? 0 : current / d1
            let mid = interpolate(from: a1, to: a2, t: t)
            path.addLine(to: mid)
            return path
        } else {
            // First line fully drawn
            path.addLine(to: a2)
        }

        // ---- Second stroke segment ----
        let remaining = current - d1
        let t2 = d2 == 0 ? 0 : min(1, remaining / d2)
        let mid2 = interpolate(from: b1, to: b2, t: t2)

        path.move(to: b1)
        path.addLine(to: mid2)

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
