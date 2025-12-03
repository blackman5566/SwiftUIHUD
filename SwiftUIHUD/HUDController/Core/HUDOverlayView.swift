//
//  HUDOverlayView.swift
//  SwiftUIHUD
//
//  Created by Allen Shu on 2025/12/3.
//

import SwiftUI

/// A full-screen overlay that displays the HUD on top of the current content.
///
/// Usage:
///
/// ```swift
/// struct RootView: View {
///     var body: some View {
///         ContentView()
///             .hudOverlay() // Attach the overlay here
///     }
/// }
/// ```
public struct HUDOverlayView: View {

    @EnvironmentObject public var hud: HUDController

    // MARK: - Internal State

    /// Keep the view alive until the hide animation finishes.
    @State private var isVisible: Bool = false

    /// Scale & opacity used to emulate UIKit keyframe animations.
    @State private var cardScale: CGFloat = 0.001
    @State private var cardOpacity: Double = 0
    @State private var maskOpacity: Double = 0

    @State private var strokeProgress: CGFloat = 0

    private let hudSize: CGFloat = 45
    private let borderGap: CGFloat = 10

    // MARK: - Animation Timing

    /// Timing values that roughly match the original UIKit keyframes.
    private enum Timing {
        static let base: Double = 0.3
        static let phase1: Double = base / 1.5   // first step
        static let phase2: Double = base / 2.0   // second step
        static let phase3: Double = base / 2.0   // third step
    }

    public init() {}

    // MARK: - Body

    public var body: some View {
        ZStack {
            if isVisible {
                // Background mask
                hud.config.maskColor
                    .opacity(maskOpacity)
                    .ignoresSafeArea()

                // Centered HUD card
                VStack(spacing: borderGap) {
                    // Main content (indicator / shapes)
                    hudBody

                    // Optional message text
                    if let message = hud.message, !message.isEmpty {
                        Text(message)
                            .foregroundStyle(hud.config.textColor)
                            .font(.system(size: 16))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 8)
                    }
                }
                .padding(.vertical, borderGap * 2)
                .padding(.horizontal, 20)
                .frame(
                    minWidth: 120,
                    maxWidth: UIScreen.main.bounds.width / 2.5
                )
                .background(hud.config.backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                .shadow(radius: 12)
                .scaleEffect(cardScale)
                .opacity(cardOpacity)
            }
        }
        // Only intercept touches when logically presented and visible.
        .allowsHitTesting(isVisible && !hud.allowUserInteraction)
        .onAppear {
            if hud.isPresented {
                runShowAnimation()
            }
        }
        .onChange(of: hud.isPresented, initial: false) { _, newValue in
            if newValue {
                runShowAnimation()
            } else {
                runHideAnimation()
            }
        }
    }

    // MARK: - HUD Body

    @ViewBuilder
    private var hudBody: some View {
        switch hud.type {
        case .loading:
            ProgressView()
                .controlSize(.large)
                .tint(.orange)
                .frame(width: hudSize, height: hudSize)

        case .success:
            CheckmarkShape(progress: strokeProgress)
                .stroke(
                    Color.orange,
                    style: StrokeStyle(
                        lineWidth: 3,
                        lineCap: .round,
                        lineJoin: .round
                    )
                )
                .frame(width: hudSize, height: hudSize)

        case .failure:
            CrossShape(progress: strokeProgress)
                .stroke(
                    Color.red,
                    style: StrokeStyle(
                        lineWidth: 3,
                        lineCap: .round,
                        lineJoin: .round
                    )
                )
                .frame(width: hudSize, height: hudSize)
        }
    }

    // MARK: - Public Triggers (UIKit-style)

    /// Triggered when `hud.isPresented` becomes true.
    private func runShowAnimation() {
        isVisible = true

        // Reset state
        cardScale = 0.001
        cardOpacity = 0
        maskOpacity = 0
        startStrokeAnimationIfNeeded()

        Task { @MainActor in
            await performShowSequence()
        }
    }

    /// Triggered when `hud.isPresented` becomes false.
    private func runHideAnimation() {
        Task { @MainActor in
            await performHideSequence()
        }
    }

    // MARK: - Show / Hide Sequences

    /// Show animation: 0.001 -> 1.1 -> 0.9 -> 1.0
    @MainActor
    private func performShowSequence() async {
        // 1) scale 0.001 -> 1.1, mask 0 -> 1, opacity 0 -> 1
        await animate(
            duration: Timing.phase1,
            animation: .easeOut(duration: Timing.phase1)
        ) {
            maskOpacity = 1
            cardScale = 1.1
            cardOpacity = 1
        }

        // 2) 1.1 -> 0.9
        await animate(
            duration: Timing.phase2,
            animation: .easeInOut(duration: Timing.phase2)
        ) {
            cardScale = 0.9
        }

        // 3) 0.9 -> 1.0
        await animate(
            duration: Timing.phase3,
            animation: .easeInOut(duration: Timing.phase3)
        ) {
            cardScale = 1.0
        }
    }

    /// Hide animation: 1.0 -> 0.9 -> 1.1 -> 0.1 + alpha 0
    @MainActor
    private func performHideSequence() async {
        // 1) mask 1 -> 0, 1.0 -> 0.9
        await animate(
            duration: Timing.phase1,
            animation: .easeInOut(duration: Timing.phase1)
        ) {
            maskOpacity = 0
            cardScale = 0.9
        }

        // 2) 0.9 -> 1.1
        await animate(
            duration: Timing.phase2,
            animation: .easeInOut(duration: Timing.phase2)
        ) {
            cardScale = 1.1
        }

        // 3) 1.1 -> 0.1 & fade out
        await animate(
            duration: Timing.phase3,
            animation: .easeInOut(duration: Timing.phase3)
        ) {
            cardOpacity = 0
            cardScale = 0.1
        }

        // Finally mark as not visible and reset for the next show.
        isVisible = false
        cardScale = 0.001
        strokeProgress = 0
    }

    // MARK: - Small Helper

    /// Wraps `withAnimation` and `Task.sleep` into a reusable helper.
    @MainActor
    private func animate(
        duration: Double,
        animation: Animation,
        _ changes: @escaping () -> Void
    ) async {
        withAnimation(animation) {
            changes()
        }
        let ns = UInt64(duration * 1_000_000_000)
        try? await Task.sleep(nanoseconds: ns)
    }

    private func startStrokeAnimationIfNeeded() {
        guard hud.type == .success || hud.type == .failure else { return }
        strokeProgress = 0
        withAnimation(.linear(duration: 0.6)) {
            strokeProgress = 1.0
        }
    }
}
