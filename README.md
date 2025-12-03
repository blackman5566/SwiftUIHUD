# ⏳ SwiftUIHUD

`SwiftUIHUD` is a lightweight and customizable heads‑up display (HUD) component for SwiftUI.  
It provides a full‑screen overlay for **loading**, **success**, and **failure** states—similar to UIKit‑based HUDs, but rebuilt with native SwiftUI patterns.

---

## 💡 Why build a custom HUD?

Even though many HUD libraries exist, SwiftUI projects often need:

- More flexible customization  
- SwiftUI‑native animation behavior  
- A lightweight, dependency‑free design  
- Easy global access without UIKit plumbing  

`SwiftUIHUD` solves these needs while staying clean, simple, and easy to extend.

---

## 🎥 Demo

<p align="center">
  <img 
    src="https://github.com/blackman5566/SwiftUIHUD/blob/main/demo.gif" 
    alt="SwiftUIHUD Demo" 
    width="320"
  />
</p>

---

## 🔧 Features

- ✅ Full‑screen overlay — blocks or allows user interaction  
- ✅ Custom show/hide animations (UIKit‑style keyframes, but in SwiftUI)  
- ✅ Loading / Success / Failure built‑in  
- ✅ Optional message text  
- ✅ Auto‑hide or manual hide  
- ✅ Simple one‑liner usage:  
  ```swift
  HUD.showLoading()
  HUD.showSuccess()
  HUD.showFailure()
  HUD.hide()
  ```  
- 🚀 Fully extensible — plug in your own shapes, animations, colors, or styles.

---

## 📦 Usage Example

### Show a loading HUD for 3 seconds
```swift
HUD.showLoading(
    "Loading...",
    allowUserInteraction: false,
    autoHideAfter: 3
)
```

### Show a loading HUD that must be hidden manually
```swift
HUD.showLoading(
    "Please wait...",
    allowUserInteraction: true,
    autoHideAfter: nil
)

// Simulate manual hide
Task {
    try? await Task.sleep(for: .seconds(2))
    HUD.hide()
}
```

### Show success
```swift
HUD.showSuccess(
    "Operation succeeded!",
    allowUserInteraction: true,
    autoHideAfter: 1.2
) {
    print("Success callback executed")
}
```

### Show failure
```swift
HUD.showFailure(
    "Something went wrong...",
    allowUserInteraction: true,
    autoHideAfter: 1.2
) {
    print("Failure callback executed")
}
```

---

## 🧩 Ideal Use Cases

- Network requests  
- Form submission  
- Login / Registration flows  
- File upload or processing  
- Any block‑UI moment needing a clean HUD

---

## 📌 Extendable Ideas

You can easily modify or extend this component to include:

- Lottie animations  
- Blurred backgrounds  
- Custom icons or spinners  
- Progress indicators  
- Specific branding or themes  

---

## 🗂️ Installation

Simply drop the `SwiftUIHUD` folder into your project.  
Add `.hudOverlay()` at the root of your app:

```swift
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .hudOverlay()
        }
    }
}
```

This attaches the global HUD engine to your entire SwiftUI view hierarchy.

---

## 📝 License

Free to use in personal or commercial projects.
No attribution required — but appreciated! 😊

