// AsyncMacroDeclarations.swift
// SwiftMacrosKit — Async & Concurrency Macro Declarations
// Category: [C] Async & Concurrency
// Author: SwiftMacrosKit Contributors

/// Wraps an async function body in a retry loop with configurable attempts and delay.
///
/// - Parameters:
///   - attempts: Number of retry attempts (default: 3).
///   - delay: Delay between retries in seconds (default: 1.0).
///
/// **Usage:** `@Retry(attempts: 3, delay: 2.0) func fetchData() async throws -> Data { ... }`
@attached(peer, names: prefixed(`_retrying_`))
public macro Retry(attempts: Int = 3, delay: Double = 1.0) = #externalMacro(module: "SwiftMacrosKitMacros", type: "RetryMacro")

/// Wraps an async function with a timeout using task groups.
///
/// - Parameter seconds: Timeout duration in seconds.
///
/// **Usage:** `@Timeout(seconds: 30) func fetchData() async throws -> Data { ... }`
@attached(peer, names: prefixed(`_withTimeout_`))
public macro Timeout(seconds: Double) = #externalMacro(module: "SwiftMacrosKitMacros", type: "TimeoutMacro")

/// Generates a debounced version of a function using Task + sleep.
///
/// - Parameter seconds: Debounce interval in seconds.
///
/// **Usage:** `@Debounce(seconds: 0.3) func search() { ... }`
@attached(peer, names: prefixed(`debounced_`), prefixed(`_debounce_`))
public macro Debounce(seconds: Double = 0.3) = #externalMacro(module: "SwiftMacrosKitMacros", type: "DebounceMacro")

/// Generates a throttled version of a function that ignores calls within a time window.
///
/// - Parameter seconds: Throttle interval in seconds.
///
/// **Usage:** `@Throttle(seconds: 1.0) func sendEvent() { ... }`
@attached(peer, names: prefixed(`throttled_`), prefixed(`_throttle_`))
public macro Throttle(seconds: Double = 1.0) = #externalMacro(module: "SwiftMacrosKitMacros", type: "ThrottleMacro")

/// Adds a custom BackgroundActor global actor for background execution.
///
/// **Usage:** `@BackgroundActor func processData() { ... }`
@attached(peer, names: named(BackgroundActor))
public macro BackgroundActor() = #externalMacro(module: "SwiftMacrosKitMacros", type: "BackgroundActorMacro")

/// Caches the result of an async function. Subsequent calls return the cached value.
///
/// **Usage:** `@AsyncCached func loadConfig() async throws -> Config { ... }`
@attached(peer, names: prefixed(`cached_`), prefixed(`invalidate_`), prefixed(`_cache_`))
public macro AsyncCached() = #externalMacro(module: "SwiftMacrosKitMacros", type: "AsyncCachedMacro")

/// Enforces N calls per time interval, throwing when exceeded.
///
/// - Parameters:
///   - calls: Maximum number of calls allowed.
///   - per: Time interval in seconds.
///
/// **Usage:** `@RateLimit(calls: 10, per: 60) func apiCall() { ... }`
@attached(peer, names: prefixed(`rateLimited_`), prefixed(`_rateLimit_`))
public macro RateLimit(calls: Int, per: Double) = #externalMacro(module: "SwiftMacrosKitMacros", type: "RateLimitMacro")

/// Generates a parallel version of a function using TaskGroup.
///
/// **Usage:** `@Concurrent func process(_ items: [Item]) -> [Result] { ... }`
@attached(peer, names: prefixed(`concurrent_`))
public macro Concurrent() = #externalMacro(module: "SwiftMacrosKitMacros", type: "ConcurrentMacro")

/// Generates a serial task queue ensuring ordered execution.
///
/// **Usage:** `@Serial class Worker { ... }`
@attached(member, names: named(_serialQueue), named(enqueue))
public macro Serial() = #externalMacro(module: "SwiftMacrosKitMacros", type: "SerialMacro")
