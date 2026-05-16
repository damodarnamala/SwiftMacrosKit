// TestingMacroDeclarations.swift
// SwiftMacrosKit — Testing & Mocking Macro Declarations
// Category: [F] Testing & Mocking
// Author: SwiftMacrosKit Contributors

/// Generates a Mock class implementing a protocol with call recording.
///
/// **Usage:** `@Mock protocol NetworkService { func fetch() -> Data }`
@attached(peer, names: prefixed(`Mock`))
public macro Mock() = #externalMacro(module: "SwiftMacrosKitMacros", type: "MockMacro")

/// Wraps all methods of a class to record invocations (spy pattern).
///
/// **Usage:** `@Spy class UserService { func getUser() -> User { ... } }`
@attached(peer, names: prefixed(`Spy`))
public macro Spy() = #externalMacro(module: "SwiftMacrosKitMacros", type: "SpyMacro")

/// Generates a stub that returns a fixed value for a function.
///
/// - Parameter returning: The fixed return value.
///
/// **Usage:** `@Stub(returning: "test") func getData() -> String { ... }`
@attached(peer, names: prefixed(`stubbed_`))
public macro Stub(returning: Any) = #externalMacro(module: "SwiftMacrosKitMacros", type: "StubMacro")

/// Generates a static fixture factory method with default values.
///
/// **Usage:** `@TestFixture struct User { let name: String; let age: Int }`
@attached(member, names: named(fixture))
public macro TestFixture() = #externalMacro(module: "SwiftMacrosKitMacros", type: "TestFixtureMacro")

/// Generates a snapshot test helper for a SwiftUI View.
///
/// **Usage:** `@Snapshot struct MyView: View { ... }`
@attached(peer)
public macro Snapshot() = #externalMacro(module: "SwiftMacrosKitMacros", type: "SnapshotMacro")

/// BDD-style test organization — wraps a code block in a "Given" scope.
///
/// **Usage:** `#Given("a user exists") { setupUser() }`
@freestanding(expression)
public macro Given(_ description: String, _ body: @escaping () -> Void) = #externalMacro(module: "SwiftMacrosKitMacros", type: "GivenMacro")

/// BDD-style test organization — wraps a code block in a "When" scope.
///
/// **Usage:** `#When("user logs in") { login() }`
@freestanding(expression)
public macro When(_ description: String, _ body: @escaping () -> Void) = #externalMacro(module: "SwiftMacrosKitMacros", type: "WhenMacro")

/// BDD-style test organization — wraps a code block in a "Then" scope.
///
/// **Usage:** `#Then("user is authenticated") { checkAuth() }`
@freestanding(expression)
public macro Then(_ description: String, _ body: @escaping () -> Void) = #externalMacro(module: "SwiftMacrosKitMacros", type: "ThenMacro")

/// Generates an XCTest performance test wrapper for a function.
///
/// **Usage:** `@Benchmark func heavyComputation() { ... }`
@attached(peer, names: prefixed(`benchmark_`))
public macro Benchmark() = #externalMacro(module: "SwiftMacrosKitMacros", type: "BenchmarkMacro")

/// Asserts that an async expression throws a specific error type.
///
/// **Usage:** `#AssertThrows(NetworkError.self) { try await api.fetch() }`
@freestanding(expression)
public macro AssertThrows(_ errorType: Any.Type, _ body: @escaping () async throws -> Void) = #externalMacro(module: "SwiftMacrosKitMacros", type: "AssertThrowsMacro")
