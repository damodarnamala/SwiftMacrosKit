// ValidationMacroDeclarations.swift
// SwiftMacrosKit — Validation Macro Declarations
// Category: [B] Validation
// Author: SwiftMacrosKit Contributors

// MARK: - @Validated

/// Validates a property value using a predicate closure on assignment.
///
/// If the predicate returns `false`, the value reverts to `oldValue`.
///
/// - Parameter predicate: A closure that takes the new value and returns `Bool`.
///
/// **Before:**
/// ```swift
/// @Validated({ $0 > 0 })
/// var count: Int = 1
/// ```
///
/// **After (expanded):**
/// ```swift
/// var count: Int = 1 {
///     didSet {
///         let validate = { $0 > 0 }
///         if !validate(count) { count = oldValue }
///     }
/// }
/// ```
@attached(accessor)
public macro Validated<T>(_ predicate: @escaping (T) -> Bool) = #externalMacro(module: "SwiftMacrosKitMacros", type: "ValidatedMacro")

/// Guards against empty `String` or `Array` values at assignment time.
///
/// Reverts to `oldValue` if the new value is empty.
///
/// **Usage:** `@NonEmpty var name: String = "default"`
@attached(accessor)
public macro NonEmpty() = #externalMacro(module: "SwiftMacrosKitMacros", type: "NonEmptyMacro")

/// Clamps a numeric property value to a specified range.
///
/// - Parameters:
///   - min: The minimum allowed value.
///   - max: The maximum allowed value.
///
/// **Usage:** `@Clamped(min: 0, max: 100) var percentage: Int = 50`
@attached(accessor)
public macro Clamped(min: Any, max: Any) = #externalMacro(module: "SwiftMacrosKitMacros", type: "ClampedMacro")

/// Validates a `String` property against a regex pattern.
///
/// - Parameter pattern: The regex pattern string to validate against.
///
/// **Usage:** `@Regex("^[0-9]+$") var code: String = "123"`
@attached(accessor)
public macro Regex(_ pattern: String) = #externalMacro(module: "SwiftMacrosKitMacros", type: "RegexValidatedMacro")

/// Validates that a `String` property contains a valid email format.
///
/// **Usage:** `@Email var email: String = "user@example.com"`
@attached(accessor)
public macro Email() = #externalMacro(module: "SwiftMacrosKitMacros", type: "EmailMacro")

/// Validates that a `String` property contains a valid URL.
///
/// **Usage:** `@URL var link: String = "https://example.com"`
@attached(accessor)
public macro URL() = #externalMacro(module: "SwiftMacrosKitMacros", type: "URLValidatedMacro")

/// Enforces a minimum count/length on a `String` or `Array` property.
///
/// - Parameter length: The minimum allowed length.
///
/// **Usage:** `@MinLength(3) var username: String = "abc"`
@attached(accessor)
public macro MinLength(_ length: Int) = #externalMacro(module: "SwiftMacrosKitMacros", type: "MinLengthMacro")

/// Enforces a maximum count/length on a `String` or `Array` property.
///
/// - Parameter length: The maximum allowed length.
///
/// **Usage:** `@MaxLength(100) var bio: String = ""`
@attached(accessor)
public macro MaxLength(_ length: Int) = #externalMacro(module: "SwiftMacrosKitMacros", type: "MaxLengthMacro")

/// Generates a force unwrap with a meaningful fatal error message for optional properties.
///
/// **Usage:** `@NotNil var value: String? = "hello"`
@attached(accessor)
public macro NotNil() = #externalMacro(module: "SwiftMacrosKitMacros", type: "NotNilMacro")

/// Asserts that a `Comparable` property value is within a specified range.
///
/// - Parameters:
///   - min: The minimum allowed value.
///   - max: The maximum allowed value.
///
/// **Usage:** `@Range(min: 1, max: 10) var level: Int = 5`
@attached(accessor)
public macro Range(min: Any, max: Any) = #externalMacro(module: "SwiftMacrosKitMacros", type: "RangeMacro")
