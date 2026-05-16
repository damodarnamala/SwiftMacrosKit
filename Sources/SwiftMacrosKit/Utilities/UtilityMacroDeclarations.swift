// UtilityMacroDeclarations.swift
// SwiftMacrosKit — Utility & Protocol Conformance Macro Declarations
// Category: [K] Utilities
// Author: SwiftMacrosKit Contributors

/// Generates Equatable conformance with customizable property selection.
///
/// **Usage:** `@EquatablePlus struct User { ... }`
@attached(member, names: named(==))
public macro EquatablePlus() = #externalMacro(module: "SwiftMacrosKitMacros", type: "EquatablePlusMacro")

/// Generates Comparable conformance based on specified keys.
///
/// - Parameter key: The property name used for comparison.
///
/// **Usage:** `@ComparablePlus(key: "age") struct Person { ... }`
@attached(member, names: named(<))
public macro ComparablePlus(key: String) = #externalMacro(module: "SwiftMacrosKitMacros", type: "ComparablePlusMacro")

/// Generates a deep-copy method for value types or reference types.
///
/// **Usage:** `@Copyable struct Config { ... }`
@attached(member, names: named(copy))
public macro Copyable() = #externalMacro(module: "SwiftMacrosKitMacros", type: "CopyableMacro")

/// Generates a human-readable description property.
///
/// **Usage:** `@StringConvertible struct User { ... }`
@attached(member, names: named(description))
public macro StringConvertible() = #externalMacro(module: "SwiftMacrosKitMacros", type: "StringConvertibleMacro")

/// Adds allCases array for enums with associated values.
///
/// **Usage:** `@CaseIterablePlus enum Theme { ... }`
@attached(member, names: named(allCases))
public macro CaseIterablePlus() = #externalMacro(module: "SwiftMacrosKitMacros", type: "CaseIterablePlusMacro")

/// Generates CodingKeys and custom init(from:) for Decodable conformance.
///
/// **Usage:** `@DecodablePlus struct APIResponse { ... }`
@attached(member, names: named(CodingKeys), named(init(from:)))
public macro DecodablePlus() = #externalMacro(module: "SwiftMacrosKitMacros", type: "DecodablePlusMacro")

/// Generates encode(to:) for Encodable conformance.
///
/// **Usage:** `@EncodablePlus struct APIRequest { ... }`
@attached(member, names: named(encode(to:)))
public macro EncodablePlus() = #externalMacro(module: "SwiftMacrosKitMacros", type: "EncodablePlusMacro")

/// Generates a peer type with a static default instance.
///
/// **Usage:** `@Defaultable struct Config { ... }`
@attached(peer, names: suffixed(Defaults))
public macro Defaultable() = #externalMacro(module: "SwiftMacrosKitMacros", type: "DefaultableMacro")

/// Adds a feature-flag gated wrapper around a function.
///
/// - Parameter flag: The name of the feature flag.
///
/// **Usage:** `@Flagged(flag: "newUI") func showDashboard() { ... }`
@attached(peer, names: prefixed(`flagged_`))
public macro Flagged(flag: String) = #externalMacro(module: "SwiftMacrosKitMacros", type: "FlaggedMacro")

/// Generates a wrapper that prints a deprecation warning at runtime.
///
/// - Parameter message: The deprecation message.
///
/// **Usage:** `@DeprecatedPlus(message: "Use newMethod instead") func oldMethod() { ... }`
@attached(peer, names: prefixed(`deprecated_`))
public macro DeprecatedPlus(message: String) = #externalMacro(module: "SwiftMacrosKitMacros", type: "DeprecatedPlusMacro")
