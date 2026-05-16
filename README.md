# SwiftMacrosKit

> A comprehensive collection of **100 production-grade Swift Macros** for Apple ecosystem development.

[![Swift 5.9+](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![Platforms](https://img.shields.io/badge/Platforms-iOS%2017%20|%20macOS%2014%20|%20tvOS%2017%20|%20watchOS%2010-blue.svg)](https://developer.apple.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## Overview

SwiftMacrosKit provides **100 carefully crafted Swift Macros** organized into **11 categories**, covering everything from creational patterns and validation to networking, security, and SwiftUI utilities. Each macro leverages Swift's compile-time macro system via `swift-syntax` to generate boilerplate code, enforce constraints, and improve developer productivity.

## Installation

### Swift Package Manager

Add SwiftMacrosKit to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/user/SwiftMacrosKit.git", from: "1.0.0")
]
```

Then add it as a dependency to your target:

```swift
.target(
    name: "YourApp",
    dependencies: ["SwiftMacrosKit"]
)
```

## Macro Catalog

### [A] Creational Patterns (12 macros)

| Macro | Type | Description |
|-------|------|-------------|
| `@Singleton` | Member | Thread-safe singleton with `shared` instance |
| `@Builder` | Member | Builder pattern with fluent API |
| `@Factory` | Member | Factory method with type registration |
| `@Prototype` | Member | Deep-copy `clone()` method |
| `@FluentBuilder` | Member | Chainable setter methods |
| `@StaticFactory` | Member | Named static factory methods |
| `@AutoInit` | Member | Memberwise initializer |
| `@DefaultInit` | Member | Default-value initializer |
| `@LazyInit` | Accessor/Peer | Lazy-initialized backing storage |
| `@Pool` | Member | Object pool with checkout/return |
| `@Multiton` | Member | Keyed singleton instances |
| `@Injectable` | Member | Dependency injection container |

### [B] Validation & Constraints (10 macros)

| Macro | Type | Description |
|-------|------|-------------|
| `@Validated` | Accessor | Custom predicate validation on `didSet` |
| `@NonEmpty` | Accessor | Rejects empty String/Array |
| `@Clamped` | Accessor | Clamps numeric value to min...max |
| `@RegexValidated` | Accessor | Regex pattern validation |
| `@Email` | Accessor | Email format validation |
| `@URLValidated` | Accessor | URL format validation |
| `@MinLength` | Accessor | Minimum length enforcement |
| `@MaxLength` | Accessor | Maximum length with truncation |
| `@NotNil` | Accessor | Nil-assignment trap |
| `@Range` | Accessor | Range assertion with precondition |

### [C] Async & Concurrency (9 macros)

| Macro | Type | Description |
|-------|------|-------------|
| `@Retry` | Peer | Automatic retry with configurable attempts |
| `@Timeout` | Peer | Timeout wrapper for async functions |
| `@Debounce` | Peer | Debounced function execution |
| `@Throttle` | Peer | Throttled function execution |
| `@BackgroundActor` | Peer | Background thread execution |
| `@AsyncCached` | Peer | Cached async results |
| `@RateLimit` | Peer | Rate-limited function calls |
| `@Concurrent` | Peer | Parallel execution via TaskGroup |
| `@Serial` | Member | Serial queue with enqueue method |

### [D] Persistence & Storage (8 macros)

| Macro | Type | Description |
|-------|------|-------------|
| `@UserDefault` | Accessor | UserDefaults-backed property |
| `@Keychain` | Accessor | Keychain-backed secure storage |
| `@CloudSync` | Accessor | iCloud KVS synced property |
| `@FileStored` | Accessor | File system persistence |
| `@Persisted` | Accessor | Generic persistence layer |
| `@CoreDataEntity` | Member | Core Data managed object setup |
| `@SwiftDataModel` | Member | SwiftData model boilerplate |
| `@Cached` | Peer | In-memory caching wrapper |

### [E] Networking (8 macros)

| Macro | Type | Description |
|-------|------|-------------|
| `@Endpoint` | Member | URL request builder with query params |
| `@GET` | Member | GET request builder |
| `@POST` | Member | POST request with JSON body |
| `@Headers` | Member | Custom header application |
| `@Bearer` | Member | Bearer token authentication |
| `@Multipart` | Member | Multipart form-data request |
| `@MockResponse` | Member | Mock HTTP response for testing |
| `@QueryParam` | Accessor | Query parameter marker |

### [F] Testing & Mocking (10 macros)

| Macro | Type | Description |
|-------|------|-------------|
| `@Mock` | Peer | Auto-generate mock class from protocol |
| `@Spy` | Peer | Spy subclass tracking invocations |
| `@Stub` | Peer | Stubbed function returning fixed values |
| `@TestFixture` | Member | Test fixture factory method |
| `@Snapshot` | Peer | SwiftUI snapshot test helper |
| `@Benchmark` | Peer | Performance benchmark wrapper |
| `#Given` | Expression | BDD-style "Given" step |
| `#When` | Expression | BDD-style "When" step |
| `#Then` | Expression | BDD-style "Then" step |
| `#AssertThrows` | Expression | Typed error assertion |

### [G] SwiftUI & UI (10 macros)

| Macro | Type | Description |
|-------|------|-------------|
| `@PreviewProvider` | Member | Multi-device preview generation |
| `@ViewState` | Member | View state struct extraction |
| `@StyleSheet` | Member | Design token constants |
| `@Themed` | Member | Color scheme environment injection |
| `@AnimatablePlus` | Member | Animatable data conformance |
| `@OrientationAware` | Member | Orientation-aware environment |
| `@SafeArea` | Member | Safe area insets reader |
| `@BindablePlus` | Accessor | Bindable property marker |
| `@Accessible` | Peer | Accessibility marker |
| `@HapticFeedback` | Peer | Haptic feedback wrapper |

### [H] Security (6 macros)

| Macro | Type | Description |
|-------|------|-------------|
| `@Encrypted` | Accessor | Encrypted property storage |
| `@Hashed` | Accessor | SHA256 hashing on set |
| `@Redacted` | Accessor | Redaction marker for logging |
| `@Sanitized` | Accessor | HTML/script tag stripping |
| `@BiometricGated` | Peer | Biometric authentication gate |
| `@SecureEnclave` | Accessor | Secure Enclave storage |

### [I] Logging & Observability (6 macros)

| Macro | Type | Description |
|-------|------|-------------|
| `@Logged` | Peer | OSLog entry/exit logging |
| `@Traced` | Peer | Instruments signpost tracing |
| `@Measured` | Peer | Execution time measurement |
| `@OSLogged` | Member | Static Logger property |
| `@Crashlytic` | Peer | Non-fatal error wrapper |
| `@Analytics` | Peer | Analytics event tracking |

### [J] Design Patterns (10 macros)

| Macro | Type | Description |
|-------|------|-------------|
| `@Observer` | Member | Observer pattern infrastructure |
| `@Command` | Member | Command pattern (execute/undo) |
| `@Decorator` | Member | Decorator wrapper base |
| `@Composite` | Member | Composite tree structure |
| `@Strategy` | Peer | Strategy pattern context |
| `@StateMachine` | Member | State machine with transitions |
| `#EventBus` | Declaration | Type-safe publish/subscribe bus |
| `@Pipeline` | Peer | Multi-stage data pipeline |
| `@CQRS` | Member | Command/Query separation |
| `@Repository` | Peer | Repository pattern implementation |

### [K] Utilities & DX (10 macros)

| Macro | Type | Description |
|-------|------|-------------|
| `@EquatablePlus` | Member | Equatable for classes |
| `@ComparablePlus` | Member | Comparable with key path |
| `@Copyable` | Member | Copy-with-modification |
| `@StringConvertible` | Member | Human-readable description |
| `@CaseIterablePlus` | Member | allCases for enums with associated values |
| `@Defaultable` | Peer | Default protocol extension |
| `@DecodablePlus` | Member | CodingKeys + init(from:) |
| `@EncodablePlus` | Member | encode(to:) generation |
| `@Flagged` | Peer | Feature flag gating |
| `@DeprecatedPlus` | Peer | Runtime deprecation warning |

## Quick Start

```swift
import SwiftMacrosKit

// Singleton pattern
@Singleton
class AppConfiguration {
    var apiKey: String = ""
}

// Validation
struct UserProfile {
    @NonEmpty var name: String = "Anonymous"
    @Clamped(min: 0, max: 150) var age: Int = 0
    @Email var email: String = "user@example.com"
}

// Persistence
struct Settings {
    @UserDefault(key: "theme", default: "light")
    var theme: String
}

// Testing mocks
@Mock
protocol DataService {
    func fetchUser() -> User
}

// State machine
@StateMachine(states: "idle, loading, loaded, error")
class ViewModel { }
```

## Requirements

- Swift 5.9+
- iOS 17+ / macOS 14+ / tvOS 17+ / watchOS 10+
- Xcode 15+

## License

MIT License. See [LICENSE](LICENSE) for details.
