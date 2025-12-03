//
//  ContentView.swift
//  SwiftUIHUD
//
//  Created by Allen Shu on 2025/12/3.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {

                // Loading + auto hide after 3 seconds
                Button("Show Loading (auto-hide in 3 seconds)") {
                    HUD.showLoading(
                        "Loading...",    // false = user cannot tap behind
                        autoHideAfter: 3                // hides automatically after 3 seconds
                    )
                }

                // Loading + manual hide
                Button("Show Loading (manual hide)") {
                    HUD.showLoading(
                        "Please wait...",     // true = user can tap behind
                        autoHideAfter: nil              // nil = will not auto-hide
                    )

                    // Simulate manually hiding after 2 seconds
                    Task {
                        try? await Task.sleep(nanoseconds: 2_000_000_000)
                        HUD.hide()
                    }
                }

                // Success HUD
                Button("Show Success") {
                    HUD.showSuccess(
                        "Operation succeeded!",     // success usually allows user interaction
                        autoHideAfter: 1.2
                    ) {
                        print("✅ Success HUD dismissed callback triggered")
                    }
                }

                // Failure HUD
                Button("Show Failure") {
                    HUD.showFailure(
                        "Something went wrong...",
                        autoHideAfter: 1.2
                    ) {
                        print("❌ Failure HUD dismissed callback triggered")
                    }
                }

                // Force hide
                Button("Hide (force)") {
                    HUD.hide()
                }
            }
            .padding()
            .navigationTitle("SwiftUIHUD Demo")
        }
    }
}

#Preview {
    ContentView()
}
