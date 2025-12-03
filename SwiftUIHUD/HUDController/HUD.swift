//
//  HUD.swift
//  SwiftUIHUD
//
//  Created by Allen Shu on 2025/12/3.
//

import SwiftUI

/// A lightweight static namespace for presenting HUDs.
///
/// Provides a clean API:
///
/// ```swift
/// HUD.showLoading("Loading...")
/// HUD.showSuccess("Done!")
/// HUD.showFailure("Something went wrong")
/// HUD.hide()
/// ```
///
/// Internally delegates to `HUDController.shared`.
public enum HUD {

    /// Shows a loading HUD.
    ///
    /// - Parameters:
    ///   - message: Optional text displayed below the indicator.
    ///   - allowUserInteraction: Whether touches pass through the overlay.
    ///   - autoHideAfter: If set, automatically hides after the delay.
    @MainActor
    public static func showLoading(
        _ message: String? = nil,
        allowUserInteraction: Bool = false,
        autoHideAfter delay: TimeInterval? = nil
    ) {
        HUDController.shared.showLoading(
            message: message,
            allowUserInteraction: allowUserInteraction,
            autoHideAfter: delay
        )
    }

    /// Shows a success HUD with a checkmark animation.
    ///
    /// - Parameters:
    ///   - message: Optional success message text.
    ///   - allowUserInteraction: Whether touches pass through the overlay.
    ///   - autoHideAfter: Auto-hide delay (default: 1 second).
    ///   - completion: Called after the HUD is dismissed.
    @MainActor
    public static func showSuccess(
        _ message: String? = nil,
        allowUserInteraction: Bool = true,
        autoHideAfter delay: TimeInterval = 1.0,
        completion: (() -> Void)? = nil
    ) {
        HUDController.shared.showSuccess(
            message: message,
            allowUserInteraction: allowUserInteraction,
            autoHideAfter: delay,
            completion: completion
        )
    }

    /// Shows a failure HUD with an X animation.
    ///
    /// - Parameters:
    ///   - message: Optional failure message text.
    ///   - allowUserInteraction: Whether touches pass through the overlay.
    ///   - autoHideAfter: Auto-hide delay (default: 1 second).
    ///   - completion: Called after the HUD is dismissed.
    @MainActor
    public static func showFailure(
        _ message: String? = nil,
        allowUserInteraction: Bool = true,
        autoHideAfter delay: TimeInterval = 1.0,
        completion: (() -> Void)? = nil
    ) {
        HUDController.shared.showFailure(
            message: message,
            allowUserInteraction: allowUserInteraction,
            autoHideAfter: delay,
            completion: completion
        )
    }

    /// Hides the currently presented HUD.
    ///
    /// - Parameter completion: Called after the HUD is dismissed.
    @MainActor
    public static func hide(_ completion: (() -> Void)? = nil) {
        HUDController.shared.hide(completion: completion)
    }
}
