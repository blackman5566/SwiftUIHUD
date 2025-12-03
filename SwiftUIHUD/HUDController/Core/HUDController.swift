//
//  HUDController.swift
//  SwiftUIHUD
//
//  Created by Allen Shu on 2025/12/3.
//

import SwiftUI

/// Represents the type of HUD to display.
public enum HUDType {
    case loading
    case success
    case failure
}

/// Configuration for HUD appearance and behavior.
public struct HUDConfig {
    /// Background color of the central HUD card.
    public var backgroundColor: Color
    /// Text color for message labels.
    public var textColor: Color
    /// Overlay mask color behind the HUD.
    public var maskColor: Color
    /// Controls whether touch events pass through to underlying views.
    public var allowUserInteraction: Bool

    public init(
        backgroundColor: Color = Color(.sRGB, red: 0.96, green: 0.96, blue: 0.96, opacity: 0.9),
        textColor: Color = Color(.sRGB, red: 0.51, green: 0.51, blue: 0.51, opacity: 1.0),
        maskColor: Color = Color.black.opacity(0.4),
        allowUserInteraction: Bool = false
    ) {
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.maskColor = maskColor
        self.allowUserInteraction = allowUserInteraction
    }
}

/// A SwiftUI-based HUD state controller.
///
/// **How to use:**
///
/// 1. Attach `.hudOverlay()` to your root view.
/// 2. Call `HUD.showLoading(...)`, `HUD.showSuccess(...)`, `HUD.showFailure(...)`,
///    or `HUD.hide()` anywhere in the app.
///
/// The controller maintains HUD states and handles auto-hide behavior.
@MainActor
public final class HUDController: ObservableObject {

    // MARK: - Singleton

    /// Shared singleton instance.
    /// If needed, you may create your own instance for custom scoping.
    public static let shared = HUDController()

    // MARK: - Published State

    /// Whether the HUD is currently presented.
    @Published public var isPresented: Bool
    /// The type of HUD being shown.
    @Published public var type: HUDType
    /// Optional message displayed under the indicator or icon.
    @Published public var message: String?
    /// Visual configuration and interaction options.
    @Published public var config: HUDConfig

    /// Whether touch events pass through the HUD overlay.
    /// (Inverse meaning: if this is false, the HUD blocks touches.)
    public var allowUserInteraction: Bool {
        config.allowUserInteraction
    }

    // MARK: - Initialization

    /// Creates a new HUDController instance.
    /// Useful for injecting custom HUD controllers if not using the shared singleton.
    public init(
        isPresented: Bool = false,
        type: HUDType = .loading,
        message: String? = nil,
        config: HUDConfig = HUDConfig()
    ) {
        self.isPresented = isPresented
        self.type = type
        self.message = message
        self.config = config
    }

    // MARK: - Public API (Equivalent to UIKit CustomHUD)

    /// Shows a loading HUD.
    ///
    /// - Parameters:
    ///   - message: Text displayed below the loading indicator.
    ///   - allowUserInteraction: If true, touches pass through the overlay.
    ///   - autoHideAfter: If non-nil, hides automatically after the delay.
    public func showLoading(
        message: String? = nil,
        allowUserInteraction: Bool = false,
        autoHideAfter delay: TimeInterval? = nil
    ) {
        config.allowUserInteraction = allowUserInteraction
        type = .loading
        self.message = message
        isPresented = true

        if let delay {
            scheduleHide(after: delay, completion: nil)
        }
    }

    /// Shows a success HUD with a checkmark animation.
    ///
    /// - Parameters:
    ///   - message: Optional success message.
    ///   - allowUserInteraction: If true, touches pass through the overlay.
    ///   - autoHideAfter: Delay before auto-hiding (default: 1 second).
    ///   - completion: Called after the HUD is dismissed.
    public func showSuccess(
        message: String? = nil,
        allowUserInteraction: Bool = false,
        autoHideAfter delay: TimeInterval = 1.0,
        completion: (() -> Void)? = nil
    ) {
        config.allowUserInteraction = allowUserInteraction
        type = .success
        self.message = message
        isPresented = true
        scheduleHide(after: delay, completion: completion)
    }

    /// Shows a failure HUD with an X animation.
    ///
    /// - Parameters:
    ///   - message: Optional failure message.
    ///   - allowUserInteraction: If true, touches pass through the overlay.
    ///   - autoHideAfter: Delay before auto-hiding (default: 1 second).
    ///   - completion: Called after the HUD is dismissed.
    public func showFailure(
        message: String? = nil,
        allowUserInteraction: Bool = false,
        autoHideAfter delay: TimeInterval = 1.0,
        completion: (() -> Void)? = nil
    ) {
        config.allowUserInteraction = allowUserInteraction
        type = .failure
        self.message = message
        isPresented = true
        scheduleHide(after: delay, completion: completion)
    }

    /// Hides the currently visible HUD.
    ///
    /// - Parameter completion: Called after the HUD is dismissed.
    public func hide(completion: (() -> Void)? = nil) {
        guard isPresented else { return }
        isPresented = false
        completion?()
    }

    // MARK: - Private Helpers

    /// Schedules the HUD to hide after the specified delay.
    private func scheduleHide(
        after delay: TimeInterval,
        completion: (() -> Void)?
    ) {
        Task { [weak self] in
            // Delay in nanoseconds
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))

            // Skip if the controller has been deallocated
            guard let self else { return }
            self.hide(completion: completion)
        }
    }
}
