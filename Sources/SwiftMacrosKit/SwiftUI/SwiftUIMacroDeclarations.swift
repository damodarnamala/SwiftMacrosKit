// SwiftUIMacroDeclarations.swift
// SwiftMacrosKit — SwiftUI & UI Macro Declarations
// Category: [G] SwiftUI & UI
// Author: SwiftMacrosKit Contributors

/// Auto-generates preview content with common device sizes.
///
/// **Usage:** `@PreviewProvider struct ContentView: View { ... }`
@attached(member, names: named(_previewContent))
public macro PreviewProvider() = #externalMacro(module: "SwiftMacrosKitMacros", type: "PreviewProviderMacro")

/// Extracts @State properties into a nested ViewState struct.
///
/// **Usage:** `@ViewState struct MyView: View { @State var count = 0 }`
@attached(member, names: named(ViewState))
public macro ViewState() = #externalMacro(module: "SwiftMacrosKitMacros", type: "ViewStateMacro")

/// Generates $binding accessor sugar for Observable class properties.
///
/// **Usage:** `@BindablePlus var viewModel: MyViewModel`
@attached(accessor)
public macro BindablePlus() = #externalMacro(module: "SwiftMacrosKitMacros", type: "BindablePlusMacro")

/// Generates static style tokens (spacing, corner radius, etc.).
///
/// **Usage:** `@StyleSheet struct AppStyles { }`
@attached(member, names: arbitrary)
public macro StyleSheet() = #externalMacro(module: "SwiftMacrosKitMacros", type: "StyleSheetMacro")

/// Injects environment theme object into a View.
///
/// **Usage:** `@Themed struct ThemedView: View { ... }`
@attached(member, names: named(colorScheme))
public macro Themed() = #externalMacro(module: "SwiftMacrosKitMacros", type: "ThemedMacro")

/// Generates accessibility label and hint modifiers.
///
/// - Parameters:
///   - label: The accessibility label.
///   - hint: The accessibility hint.
///
/// **Usage:** `@Accessible(label: "Submit", hint: "Submits the form") struct SubmitButton { ... }`
@attached(peer)
public macro Accessible(label: String, hint: String) = #externalMacro(module: "SwiftMacrosKitMacros", type: "AccessibleMacro")

/// Generates animatableData conformance for Animatable types.
///
/// **Usage:** `@AnimatablePlus struct AnimatedShape { var progress: Double }`
@attached(member, names: named(animatableData))
public macro AnimatablePlus() = #externalMacro(module: "SwiftMacrosKitMacros", type: "AnimatablePlusMacro")

/// Wraps a function or action with UIImpactFeedbackGenerator haptic trigger.
///
/// - Parameter style: The haptic feedback style (default: .medium).
///
/// **Usage:** `@HapticFeedback(style: .heavy) func onTap() { ... }`
@attached(peer, names: suffixed(`WithHaptic`))
public macro HapticFeedback(style: String = ".medium") = #externalMacro(module: "SwiftMacrosKitMacros", type: "HapticFeedbackMacro")

/// Injects horizontal/vertical size class environment values and orientation helpers.
///
/// **Usage:** `@OrientationAware struct ResponsiveView: View { ... }`
@attached(member, names: named(horizontalSizeClass), named(verticalSizeClass), named(isLandscape), named(isPortrait))
public macro OrientationAware() = #externalMacro(module: "SwiftMacrosKitMacros", type: "OrientationAwareMacro")

/// Injects safe area insets environment values.
///
/// **Usage:** `@SafeArea struct FullScreenView: View { ... }`
@attached(member, names: named(SafeAreaReader))
public macro SafeArea() = #externalMacro(module: "SwiftMacrosKitMacros", type: "SafeAreaMacro")
