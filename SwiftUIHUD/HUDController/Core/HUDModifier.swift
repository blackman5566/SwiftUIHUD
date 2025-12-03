//
//  HUDModifier.swift
//  SwiftUIHUD
//
//  Created by 許佳豪 on 2025/12/3.
//

import SwiftUI

// MARK: - View Modifier & Extension

/// A modifier that overlays the HUD on top of the entire view hierarchy.
public struct HUDModifier: ViewModifier {

    @StateObject private var hud = HUDController.shared

    public init() {}

    public func body(content: Content) -> some View {
        ZStack {
            content
            HUDOverlayView()
                .environmentObject(hud)
        }
    }
}

public extension View {

    /// Attaches a HUD overlay to the current view.
    ///
    /// Typically used at the app root:
    ///
    /// ```swift
    /// @main
    /// struct MyApp: App {
    ///     var body: some Scene {
    ///         WindowGroup {
    ///             RootView()
    ///                 .hudOverlay()
    ///         }
    ///     }
    /// }
    /// ```
    func hudOverlay() -> some View {
        self.modifier(HUDModifier())
    }
}
