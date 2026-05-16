// LoggingMacroDeclarations.swift
// SwiftMacrosKit — Logging & Observability Macro Declarations
// Category: [I] Logging & Observability
// Author: SwiftMacrosKit Contributors

/// Logs function entry (with args) and exit (with result) via OSLog.
///
/// - Parameter level: The log level (default: .default).
///
/// **Usage:** `@Logged(level: .info) func processData() -> Result { ... }`
@attached(peer, names: prefixed(`logged_`))
public macro Logged(level: String = ".default") = #externalMacro(module: "SwiftMacrosKitMacros", type: "LoggedMacro")

/// Emits signpost begin/end for Instruments tracing on async functions.
///
/// **Usage:** `@Traced func loadData() async throws { ... }`
@attached(peer, names: prefixed(`traced_`))
public macro Traced() = #externalMacro(module: "SwiftMacrosKitMacros", type: "TracedMacro")

/// Measures and logs execution time with a high-resolution clock.
///
/// **Usage:** `@Measured func heavyComputation() -> Int { ... }`
@attached(peer, names: prefixed(`measured_`))
public macro Measured() = #externalMacro(module: "SwiftMacrosKitMacros", type: "MeasuredMacro")

/// Generates a private static Logger property for the attached type.
///
/// - Parameters:
///   - subsystem: The OSLog subsystem identifier.
///   - category: The OSLog category.
///
/// **Usage:** `@OSLogged(subsystem: "com.app", category: "network") class API { ... }`
@attached(member, names: named(logger))
public macro OSLogged(subsystem: String, category: String) = #externalMacro(module: "SwiftMacrosKitMacros", type: "OSLoggedMacro")

/// Wraps function in do/catch and records error as non-fatal.
///
/// **Usage:** `@Crashlytic func riskyOperation() throws { ... }`
@attached(peer, names: prefixed(`safe_`))
public macro Crashlytic() = #externalMacro(module: "SwiftMacrosKitMacros", type: "CrashlyticMacro")

/// Fires an analytics event (pluggable AnalyticsProvider protocol).
///
/// - Parameter event: The analytics event name.
///
/// **Usage:** `@Analytics(event: "button_tap") func onTap() { ... }`
@attached(peer, names: prefixed(`tracked_`))
public macro Analytics(event: String) = #externalMacro(module: "SwiftMacrosKitMacros", type: "AnalyticsMacro")
