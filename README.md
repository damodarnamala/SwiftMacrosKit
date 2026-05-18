# SwiftMacrosKit

**100 production-grade Swift Macros for the Apple ecosystem.**

SwiftMacrosKit is a comprehensive, open-source collection of Swift macros organized into 11 categories — from creational patterns and validation to networking, security, SwiftUI helpers, and more. Each macro eliminates boilerplate, enforces best practices, and keeps your codebase clean and expressive.

[![Swift 5.9+](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![Platforms](https://img.shields.io/badge/Platforms-iOS%2017%20|%20macOS%2014%20|%20tvOS%2017%20|%20watchOS%2010-blue.svg)](https://developer.apple.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

---

## Table of Contents

- [Installation](#installation)
- [Quick Start](#quick-start)
- [Macro Categories](#macro-categories)
  - [A — Creational Patterns (12)](#a--creational-patterns)
  - [B — Validation & Constraints (10)](#b--validation--constraints)
  - [C — Async & Concurrency (9)](#c--async--concurrency)
  - [D — Persistence & Storage (8)](#d--persistence--storage)
  - [E — Networking (8)](#e--networking)
  - [F — Testing & Mocking (10)](#f--testing--mocking)
  - [G — SwiftUI & UI (10)](#g--swiftui--ui)
  - [H — Security (6)](#h--security)
  - [I — Logging & Observability (6)](#i--logging--observability)
  - [J — Design Patterns (10)](#j--design-patterns)
  - [K — Utilities & DX (10)](#k--utilities--dx)
- [Requirements](#requirements)
- [Contributing](#contributing)
- [License](#license)

---

## Installation

### Swift Package Manager

Add SwiftMacrosKit to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/aspect-build/SwiftMacrosKit.git", from: "1.0.0")
]
```

Then add it to your target:

```swift
.target(
    name: "YourApp",
    dependencies: ["SwiftMacrosKit"]
)
```

Or in **Xcode**: File → Add Package Dependencies → paste the repository URL.

### Import

```swift
import SwiftMacrosKit
```

---

## Quick Start

```swift
import SwiftMacrosKit

// Turn any class into a thread-safe singleton — one line
@Singleton
class NetworkManager {
    var baseURL: String = ""
}

// Type-safe UserDefaults — no more stringly-typed keys
struct Preferences {
    @UserDefault(key: "theme", default: "light")
    var theme: String
}

// Auto-generate a fluent builder
@Builder
struct User {
    let name: String
    let age: Int
    let email: String?
}

let user = User.Builder()
    .setName("Alice")
    .setAge(30)
    .setEmail("alice@example.com")
    .build()
```

---

## Macro Categories

### A — Creational Patterns

12 macros for object creation, initialization, and lifecycle management.

#### `@Singleton`

Transforms a class into a thread-safe singleton with `static let shared` and `private init()`.

```swift
@Singleton
class Analytics {
    var isEnabled = true
}

// Usage
Analytics.shared.isEnabled = false
```

<details>
<summary>Expanded code</summary>

```swift
class Analytics {
    var isEnabled = true
    static let shared = Analytics()
    private init() {}
}
```
</details>

---

#### `@Builder`

Generates an inner `Builder` class with fluent `set` methods and a `build()` method.

```swift
@Builder
struct User {
    let name: String
    let age: Int
    let email: String?
}

// Usage
let user = User.Builder()
    .setName("Alice")
    .setAge(30)
    .setEmail("alice@example.com")
    .build()
```

<details>
<summary>Expanded code</summary>

```swift
struct User {
    let name: String
    let age: Int
    let email: String?

    class Builder {
        private var name: String?
        private var age: Int?
        private var email: String?

        func setName(_ value: String) -> Builder { self.name = value; return self }
        func setAge(_ value: Int) -> Builder { self.age = value; return self }
        func setEmail(_ value: String?) -> Builder { self.email = value; return self }

        func build() -> User {
            User(name: name!, age: age!, email: email)
        }
    }
}
```
</details>

---

#### `@Factory`

Generates static factory methods for each case of an enum.

```swift
@Factory
enum Shape {
    case circle(radius: Double)
    case rectangle(width: Double, height: Double)
    case point
}

// Usage
let shape = Shape.makeCircle(radius: 5.0)
```

<details>
<summary>Expanded code</summary>

```swift
enum Shape {
    case circle(radius: Double)
    case rectangle(width: Double, height: Double)
    case point

    static func makeCircle(radius: Double) -> Shape { .circle(radius: radius) }
    static func makeRectangle(width: Double, height: Double) -> Shape { .rectangle(width: width, height: height) }
    static func makePoint() -> Shape { .point }
}
```
</details>

---

#### `@Prototype`

Generates a `copy()` method that deep-copies all stored properties into a new instance.

```swift
@Prototype
class Document {
    var title: String = ""
    var content: String = ""
}

// Usage
let original = Document()
original.title = "Draft"
let clone = original.copy()
```

<details>
<summary>Expanded code</summary>

```swift
class Document {
    var title: String = ""
    var content: String = ""

    func copy() -> Document {
        let clone = Document()
        clone.title = self.title
        clone.content = self.content
        return clone
    }
}
```
</details>

---

#### `@FluentBuilder`

Generates `with<PropertyName>` methods for chained immutable configuration.

```swift
@FluentBuilder
struct Config {
    var host: String = ""
    var port: Int = 8080
}

// Usage
let config = Config()
    .withHost("localhost")
    .withPort(3000)
```

<details>
<summary>Expanded code</summary>

```swift
struct Config {
    var host: String = ""
    var port: Int = 8080

    func withHost(_ value: String) -> Config {
        var copy = self
        copy.host = value
        return copy
    }
    func withPort(_ value: Int) -> Config {
        var copy = self
        copy.port = value
        return copy
    }
}
```
</details>

---

#### `@StaticFactory(_ name:)`

Generates a named static factory method for a struct.

```swift
@StaticFactory("create")
struct Point {
    var x: Double
    var y: Double
}

// Usage
let point = Point.create(x: 1.0, y: 2.0)
```

---

#### `@LazyInit`

Generates thread-safe lazy initialization for a property using a closure.

```swift
struct Service {
    @LazyInit({ ExpensiveObject() })
    var engine: ExpensiveObject
}

// engine is created on first access, then cached
```

---

#### `@Pool`

Generates an object pool with `acquire()` and `release()` static methods.

```swift
@Pool
class Connection {
    var isActive = false
}

// Usage
let conn = Connection.acquire()
conn.isActive = true
// ... use connection ...
Connection.release(conn)
```

<details>
<summary>Expanded code</summary>

```swift
class Connection {
    var isActive = false

    private static var pool: [Connection] = []
    private static let poolLock = NSLock()

    static func acquire() -> Connection {
        poolLock.lock()
        defer { poolLock.unlock() }
        if let obj = pool.popLast() { return obj }
        return Connection()
    }
    static func release(_ obj: Connection) {
        poolLock.lock()
        defer { poolLock.unlock() }
        pool.append(obj)
    }
}
```
</details>

---

#### `@Multiton`

Generates a keyed-singleton pattern — one shared instance per key.

```swift
@Multiton
class Logger {
    var tag: String = ""
}

// Usage
let networkLogger = Logger.instance(for: "network")
let uiLogger = Logger.instance(for: "ui")
```

<details>
<summary>Expanded code</summary>

```swift
class Logger {
    var tag: String = ""

    private static var instances: [String: Logger] = [:]
    private static let instancesLock = NSLock()

    static func instance(for key: String) -> Logger {
        instancesLock.lock()
        defer { instancesLock.unlock() }
        if let existing = instances[key] { return existing }
        let new = Logger()
        instances[key] = new
        return new
    }
}
```
</details>

---

#### `@Injectable`

Generates a dependency injection initializer and a static `dependencies` list.

```swift
@Injectable(NetworkService.self, DatabaseService.self)
class UserRepository {
    let network: NetworkService
    let database: DatabaseService
}

// Usage
let repo = UserRepository(network: myNetwork, database: myDB)
```

---

#### `@AutoInit`

Generates a memberwise initializer for all stored properties (optional properties default to `nil`).

```swift
@AutoInit
struct User {
    let name: String
    let age: Int
    var email: String?
}

// Generated: init(name: String, age: Int, email: String? = nil)
```

---

#### `@DefaultInit`

Generates an `init()` using default values declared on each property.

```swift
@DefaultInit
struct Settings {
    var theme: String = "light"
    var fontSize: Int = 14
}

// Usage
let settings = Settings() // theme: "light", fontSize: 14
```

---

### B — Validation & Constraints

10 macros for property-level validation that guard your data at the point of assignment.

#### `@Validated`

Validates a property using a custom predicate closure. Assignment is silently ignored if the predicate returns `false`.

```swift
struct Score {
    @Validated({ $0 >= 0 && $0 <= 100 })
    var value: Int = 50
}

var score = Score()
score.value = 110  // Ignored — predicate fails
score.value = 85   // Accepted
```

---

#### `@NonEmpty`

Guards against empty `String` or `Array` assignments.

```swift
struct Profile {
    @NonEmpty var name: String = "Unknown"
}

var profile = Profile()
profile.name = ""        // Ignored — empty string
profile.name = "Alice"   // Accepted
```

---

#### `@Clamped(min:max:)`

Clamps a numeric property to a given range.

```swift
struct Volume {
    @Clamped(min: 0, max: 100)
    var level: Int = 50
}

var vol = Volume()
vol.level = 150  // Clamped to 100
vol.level = -10  // Clamped to 0
```

---

#### `@RegexValidated`

Validates a `String` property against a regex pattern.

```swift
struct Form {
    @RegexValidated("^[0-9]{5}$")
    var zipCode: String = "12345"
}

var form = Form()
form.zipCode = "abc"    // Ignored — doesn't match pattern
form.zipCode = "90210"  // Accepted
```

---

#### `@Email`

Validates that a `String` contains a valid email format.

```swift
struct Account {
    @Email var email: String = "user@example.com"
}

var account = Account()
account.email = "not-an-email"       // Ignored
account.email = "alice@domain.com"   // Accepted
```

---

#### `@URLValidated`

Validates that a `String` is a valid URL.

```swift
struct Bookmark {
    @URLValidated var link: String = "https://example.com"
}

var bm = Bookmark()
bm.link = "not a url"               // Ignored
bm.link = "https://swift.org"       // Accepted
```

---

#### `@MinLength`

Enforces a minimum character length on a `String` property.

```swift
struct Password {
    @MinLength(8) var value: String = "defaultpw"
}

var pw = Password()
pw.value = "short"          // Ignored — less than 8 characters
pw.value = "securepassword" // Accepted
```

---

#### `@MaxLength`

Enforces a maximum character length on a `String` property.

```swift
struct Tweet {
    @MaxLength(280) var text: String = ""
}
```

---

#### `@NotNil`

Provides a runtime assertion that an optional property is never set to `nil`.

```swift
struct Config {
    @NotNil var apiKey: String? = "key123"
}
```

---

#### `@Range`

Constrains a numeric property to a closed range (similar to `@Clamped` but with range syntax).

```swift
struct Temperature {
    @Range(min: -40, max: 60)
    var celsius: Double = 20.0
}
```

---

### C — Async & Concurrency

9 macros for safer, more expressive asynchronous and concurrent code.

#### `@Retry(attempts:delay:)`

Wraps an async function in a retry loop with configurable attempts and delay between retries.

```swift
@Retry(attempts: 3, delay: 2.0)
func fetchData() async throws -> Data {
    try await api.getData()
}

// Generated peer: _retrying_fetchData() — retries up to 3 times with 2s delay
```

---

#### `@Timeout(seconds:)`

Wraps an async function with a timeout using task groups. Throws if the timeout is exceeded.

```swift
@Timeout(seconds: 30)
func fetchData() async throws -> Data {
    try await api.getData()
}

// Generated peer: _withTimeout_fetchData() — cancels after 30 seconds
```

---

#### `@Debounce(seconds:)`

Generates a debounced version of a function — delays execution until calls stop for the specified interval.

```swift
@Debounce(seconds: 0.3)
func search(query: String) {
    performSearch(query)
}

// Usage: call debounced_search(query:) — only fires after 0.3s of inactivity
```

---

#### `@Throttle(seconds:)`

Generates a throttled version of a function — ignores calls within the time window.

```swift
@Throttle(seconds: 1.0)
func sendAnalyticsEvent() {
    analytics.track("scroll")
}

// Usage: throttled_sendAnalyticsEvent() — at most once per second
```

---

#### `@BackgroundActor`

Adds a custom `BackgroundActor` global actor for background execution.

```swift
@BackgroundActor
func processImages() {
    // Runs on a dedicated background executor
}
```

---

#### `@AsyncCached`

Caches the result of an async function. Subsequent calls return the cached value instantly.

```swift
@AsyncCached
func loadConfig() async throws -> Config {
    try await fetchRemoteConfig()
}

// First call fetches; subsequent calls return cache
// Call invalidate_loadConfig() to clear the cache
```

---

#### `@RateLimit(calls:per:)`

Enforces a maximum number of calls per time interval. Throws when exceeded.

```swift
@RateLimit(calls: 10, per: 60)
func apiCall() {
    // Maximum 10 calls per 60 seconds
}
```

---

#### `@Concurrent`

Generates a parallel version of a function using `TaskGroup`.

```swift
@Concurrent
func processItems(_ items: [Item]) -> [Result] {
    items.map { process($0) }
}

// Generated peer: concurrent_processItems() — processes in parallel
```

---

#### `@Serial`

Generates a serial task queue ensuring ordered execution within a type.

```swift
@Serial
class DatabaseWriter {
    func write(_ data: Data) { /* ... */ }
}

// Adds _serialQueue and enqueue() method for FIFO ordering
```

---

### D — Persistence & Storage

8 macros for data persistence across UserDefaults, Keychain, iCloud, files, and more.

#### `@UserDefault(key:default:)`

Provides type-safe `UserDefaults` get/set for a property.

```swift
struct Preferences {
    @UserDefault(key: "theme", default: "light")
    var theme: String

    @UserDefault(key: "launchCount", default: 0)
    var launchCount: Int
}

var prefs = Preferences()
prefs.theme = "dark"          // Writes to UserDefaults
print(prefs.theme)            // Reads from UserDefaults
```

---

#### `@Keychain(service:account:)`

Read/write a `String`/`Data` property via the Keychain.

```swift
struct Credentials {
    @Keychain(service: "com.myapp", account: "authToken")
    var token: String?
}

var creds = Credentials()
creds.token = "eyJhbGci..."  // Stored securely in Keychain
```

---

#### `@CloudSync(key:)`

Backs a property with `NSUbiquitousKeyValueStore` for iCloud sync.

```swift
struct SyncedPrefs {
    @CloudSync(key: "userPreferences")
    var preferences: String?
}
```

---

#### `@FileStored(path:)`

JSON encode/decode a `Codable` property to a file at the given path.

```swift
struct AppData {
    @FileStored(path: "config.json")
    var config: Config?
}
```

---

#### `@CoreDataEntity`

Generates `NSManagedObject` subclass boilerplate for Core Data.

```swift
@CoreDataEntity
class User {
    var name: String
    var age: Int
}
```

---

#### `@SwiftDataModel`

Adds `@Model` conformance and relationship annotations for SwiftData.

```swift
@SwiftDataModel
class Todo {
    var title: String
    var done: Bool
}
```

---

#### `@Cached(ttl:)`

In-memory `NSCache`-backed caching with time-to-live (TTL).

```swift
@Cached(ttl: 60)
func fetchProfile() -> Profile {
    api.getProfile()
}

// First call computes; subsequent calls within 60s return cached result
```

---

#### `@Persisted`

Abstract persistence layer with a pluggable backend.

```swift
struct AppState {
    @Persisted var settings: AppSettings?
}
```

---

### E — Networking

8 macros for building URL requests, handling authentication, and mocking network responses.

#### `@Endpoint(path:method:)`

Generates a `URLRequest` builder from struct properties.

```swift
@Endpoint(path: "/users", method: "GET")
struct FetchUsers {
    var page: Int = 1
    var limit: Int = 20
}

// Usage
let request = FetchUsers(page: 2).asURLRequest()
```

---

#### `@GET(_ path:)`

Shorthand for `@Endpoint` with `GET` method.

```swift
@GET("/users")
struct FetchUsers {
    var page: Int = 1
}

let request = FetchUsers().asURLRequest()
```

---

#### `@POST(_ path:)`

Shorthand for `@Endpoint` with `POST` method.

```swift
@POST("/users")
struct CreateUser {
    var name: String
    var email: String
}
```

---

#### `@Headers`

Merges the provided headers into a generated `URLRequest`.

```swift
@Headers(["Accept": "application/json", "X-API-Version": "2"])
struct APIRequest {
    // ...
}

// Generated: applyHeaders(to:) method
```

---

#### `@QueryParam`

Marks a property to be encoded as a URL query parameter.

```swift
struct SearchRequest {
    @QueryParam var query: String
    @QueryParam var page: Int = 1
}
```

---

#### `@Bearer`

Injects an `Authorization: Bearer` header from a token provider.

```swift
@Bearer
struct AuthenticatedRequest {
    // Generated: applyBearerToken(to:) method
}
```

---

#### `@Multipart`

Generates a `multipart/form-data` encoded `URLRequest`.

```swift
@Multipart
struct UploadRequest {
    var file: Data
    var fileName: String
}

// Generated: asMultipartRequest() method
```

---

#### `@MockResponse(json:statusCode:)`

Generates a mock `URLSession` response that returns provided JSON — perfect for testing.

```swift
@MockResponse(json: "{\"ok\": true}", statusCode: 200)
struct TestEndpoint {
    // Generated: mockData property
}
```

---

### F — Testing & Mocking

10 macros for mocking, stubbing, BDD-style testing, and benchmarking.

#### `@Mock`

Generates a `Mock` class implementing a protocol with call recording.

```swift
@Mock
protocol NetworkService {
    func fetch(url: URL) async throws -> Data
}

// Generated: MockNetworkService with call tracking
let mock = MockNetworkService()
```

---

#### `@Spy`

Wraps all methods of a class to record invocations (spy pattern).

```swift
@Spy
class UserService {
    func getUser(id: Int) -> User { /* ... */ }
}

// Generated: SpyUserService that records all method calls
```

---

#### `@Stub(returning:)`

Generates a stub that returns a fixed value for a function.

```swift
@Stub(returning: "test data")
func getData() -> String {
    fatalError("not implemented")
}

// Generated: stubbed_getData() always returns "test data"
```

---

#### `@TestFixture`

Generates a static `fixture()` factory method with sensible default values.

```swift
@TestFixture
struct User {
    let name: String
    let age: Int
}

// Usage in tests
let user = User.fixture() // Pre-filled defaults
```

---

#### `@Snapshot`

Generates a snapshot test helper for a SwiftUI View.

```swift
@Snapshot
struct ProfileCard: View {
    var body: some View { /* ... */ }
}
```

---

#### `@Benchmark`

Generates an XCTest performance test wrapper for a function.

```swift
@Benchmark
func sortLargeArray() {
    var arr = (0..<10000).shuffled()
    arr.sort()
}

// Generated: benchmark_sortLargeArray() with measure block
```

---

#### `#Given`, `#When`, `#Then`

BDD-style test organization macros for readable, structured tests.

```swift
func testUserLogin() {
    #Given("a registered user") {
        let user = User.fixture()
        registerUser(user)
    }

    #When("the user logs in") {
        loginService.login(user)
    }

    #Then("the user is authenticated") {
        XCTAssertTrue(auth.isAuthenticated)
    }
}
```

---

#### `#AssertThrows`

Asserts that an async expression throws a specific error type.

```swift
#AssertThrows(NetworkError.self) {
    try await api.fetchInvalidEndpoint()
}
```

---

### G — SwiftUI & UI

10 macros for SwiftUI views, theming, accessibility, haptics, and responsive layouts.

#### `@PreviewProvider`

Auto-generates preview content with common device sizes.

```swift
@PreviewProvider
struct ContentView: View {
    var body: some View {
        Text("Hello, World!")
    }
}
```

---

#### `@ViewState`

Extracts `@State` properties into a nested `ViewState` struct for cleaner state management.

```swift
@ViewState
struct CounterView: View {
    @State var count = 0
    @State var isActive = false

    var body: some View { /* ... */ }
}

// Generated: CounterView.ViewState struct
```

---

#### `@BindablePlus`

Generates `$binding` accessor sugar for `Observable` class properties.

```swift
struct MyView: View {
    @BindablePlus var viewModel: MyViewModel
    // ...
}
```

---

#### `@StyleSheet`

Generates static style tokens (spacing, corner radius, colors, etc.).

```swift
@StyleSheet
struct AppStyles {}

// Generated: static spacing, cornerRadius, and other tokens
```

---

#### `@Themed`

Injects an environment color scheme object into a View.

```swift
@Themed
struct ThemedView: View {
    var body: some View { /* ... */ }
}

// Generated: colorScheme environment property
```

---

#### `@Accessible(label:hint:)`

Generates accessibility label and hint modifiers.

```swift
@Accessible(label: "Submit", hint: "Submits the form")
struct SubmitButton: View {
    var body: some View {
        Button("Submit") { /* ... */ }
    }
}
```

---

#### `@AnimatablePlus`

Generates `animatableData` conformance for `Animatable` types.

```swift
@AnimatablePlus
struct AnimatedShape {
    var progress: Double
}

// Generated: animatableData computed property
```

---

#### `@HapticFeedback(style:)`

Wraps a function with `UIImpactFeedbackGenerator` haptic trigger.

```swift
@HapticFeedback(style: .heavy)
func onTap() {
    // your action
}

// Generated: onTapWithHaptic() — triggers haptic then runs body
```

---

#### `@OrientationAware`

Injects horizontal/vertical size class environment values and orientation helpers.

```swift
@OrientationAware
struct ResponsiveView: View {
    var body: some View { /* ... */ }
}

// Generated: horizontalSizeClass, verticalSizeClass, isLandscape, isPortrait
```

---

#### `@SafeArea`

Injects safe area insets environment values.

```swift
@SafeArea
struct FullScreenView: View {
    var body: some View { /* ... */ }
}

// Generated: SafeAreaReader helper
```

---

### H — Security

6 macros for encryption, hashing, biometrics, and data protection.

#### `@Encrypted(algorithm:)`

Encrypts on set, decrypts on get using CryptoKit.

```swift
struct SecureStorage {
    @Encrypted(algorithm: .aes)
    var secret: String
}

var storage = SecureStorage()
storage.secret = "sensitive data"  // Encrypted at rest
print(storage.secret)              // Decrypted on access
```

---

#### `@Hashed(using:)`

One-way hash on assignment using SHA256/SHA512. Perfect for passwords.

```swift
struct Account {
    @Hashed(using: .sha256)
    var password: String
}

var account = Account()
account.password = "mypassword"   // Stored as SHA256 hash
```

---

#### `@Redacted`

Replaces the value with `"***"` in `CustomStringConvertible` output and logs.

```swift
struct User {
    var name: String
    @Redacted var ssn: String
}

let user = User(name: "Alice", ssn: "123-45-6789")
print(user.ssn) // "***"
```

---

#### `@Sanitized`

Strips HTML/script tags and trims whitespace on assignment — prevents XSS in user input.

```swift
struct Comment {
    @Sanitized var body: String
}

var comment = Comment()
comment.body = "<script>alert('xss')</script>Hello"
print(comment.body) // "Hello"
```

---

#### `@BiometricGated`

Wraps function execution behind `LAContext` biometric evaluation (Face ID / Touch ID).

```swift
@BiometricGated
func showSecretData() {
    displaySensitiveInfo()
}

// Generated: biometricGated_showSecretData() — requires biometric auth
```

---

#### `@SecureEnclave`

Stores/retrieves data using Secure Enclave key pair via CryptoKit.

```swift
struct VaultStorage {
    @SecureEnclave var sensitiveData: Data
}
```

---

### I — Logging & Observability

6 macros for structured logging, tracing, performance measurement, and analytics.

#### `@Logged(level:)`

Logs function entry (with arguments) and exit (with result) via `OSLog`.

```swift
@Logged(level: .info)
func processOrder(id: Int) -> Bool {
    // ...
}

// Console: [INFO] processOrder(id: 42) entered
// Console: [INFO] processOrder(id: 42) returned true
```

---

#### `@Traced`

Emits signpost begin/end for Instruments tracing on async functions.

```swift
@Traced
func loadData() async throws {
    // Visible as a time interval in Instruments
}
```

---

#### `@Measured`

Measures and logs execution time with a high-resolution clock.

```swift
@Measured
func heavyComputation() -> Int {
    (0..<1_000_000).reduce(0, +)
}

// Console: heavyComputation took 0.042s
```

---

#### `@OSLogged(subsystem:category:)`

Generates a private static `Logger` property for the attached type.

```swift
@OSLogged(subsystem: "com.myapp", category: "network")
class APIClient {
    func fetch() {
        Self.logger.info("Fetching data...")
    }
}
```

---

#### `@Crashlytic`

Wraps a function in `do/catch` and records errors as non-fatal events.

```swift
@Crashlytic
func riskyOperation() throws {
    try dangerousWork()
}

// Generated: safe_riskyOperation() — catches and reports errors
```

---

#### `@Analytics(event:)`

Fires an analytics event (pluggable `AnalyticsProvider` protocol).

```swift
@Analytics(event: "button_tap")
func onTap() {
    // action
}

// Generated: tracked_onTap() — fires "button_tap" event
```

---

### J — Design Patterns

10 macros implementing classic and modern design patterns.

#### `@Observer`

Generates an observer list with `subscribe`/`notify` helpers (Observer pattern).

```swift
@Observer
class EventEmitter {
    // ...
}

// Generated: observers, addObserver(_:), removeObserver(_:), notifyObservers()
```

---

#### `@Command`

Encapsulates methods as undoable command objects (Command pattern).

```swift
@Command
struct SaveCommand {
    // ...
}

// Generated: execute() and undo() methods
```

---

#### `@Decorator`

Creates a wrapper type that intercepts calls for decoration (Decorator pattern).

```swift
@Decorator
protocol Drawable {
    func draw()
}
```

---

#### `@Composite`

Adds `children` array and leaf/composite helpers (Composite pattern).

```swift
@Composite
class UIComponent {
    // ...
}

// Generated: children, add(_:), remove(_:)
```

---

#### `@Strategy`

Generates a protocol and context for swappable algorithms (Strategy pattern).

```swift
@Strategy
struct SortingStrategy {
    func sort(_ items: [Int]) -> [Int] { items.sorted() }
}

// Generated: SortingStrategyProtocol + SortingStrategyContext
```

---

#### `@StateMachine(states:)`

Adds a state enum, transition method, and validation for finite state machines.

```swift
@StateMachine(states: "idle, loading, loaded, error")
class ViewModel {
    // ...
}

// Generated: State enum, currentState, transition(to:)
```

---

#### `#EventBus(events:)`

Generates a type-safe event bus for publish/subscribe. (Freestanding declaration)

```swift
#EventBus(events: "userLoggedIn, dataLoaded, errorOccurred")

// Generated: EventBus class with typed subscribe/publish methods
```

---

#### `@Pipeline`

Creates a multi-stage pipeline for chaining transforms (Pipeline pattern).

```swift
@Pipeline
struct ImagePipeline {
    func resize() { /* ... */ }
    func filter() { /* ... */ }
}

// Generated: ImagePipelineRunner for chained execution
```

---

#### `@CQRS`

Splits a struct into a command model and a query model (CQRS pattern).

```swift
@CQRS
struct UserService {
    var name: String
    var email: String
}

// Generated: CommandModel and QueryModel inner types
```

---

#### `@Repository`

Generates a repository protocol and default implementation.

```swift
@Repository
struct User {
    let id: UUID
    var name: String
}

// Generated: UserRepositoryProtocol + UserRepository
```

---

### K — Utilities & DX

10 macros for protocol conformance, codegen, feature flags, and developer experience.

#### `@EquatablePlus`

Generates `Equatable` conformance with customizable property selection.

```swift
@EquatablePlus
struct User {
    let id: UUID
    var name: String
    var age: Int
}

// Generated: static func == comparing all stored properties
```

---

#### `@ComparablePlus(key:)`

Generates `Comparable` conformance based on a specified key.

```swift
@ComparablePlus(key: "age")
struct Person {
    let name: String
    let age: Int
}

let sorted = people.sorted() // Sorted by age
```

---

#### `@Copyable`

Generates a `copy()` method for value types or reference types.

```swift
@Copyable
struct Config {
    var host: String
    var port: Int
}

let copy = config.copy()
```

---

#### `@StringConvertible`

Generates a human-readable `description` property.

```swift
@StringConvertible
struct User {
    let name: String
    let age: Int
}

print(User(name: "Alice", age: 30))
// "User(name: Alice, age: 30)"
```

---

#### `@CaseIterablePlus`

Adds `allCases` array for enums with associated values (where `CaseIterable` doesn't work).

```swift
@CaseIterablePlus
enum Theme {
    case light
    case dark
    case custom(name: String)
}

// Generated: static var allCases
```

---

#### `@DecodablePlus`

Generates `CodingKeys` and custom `init(from:)` for `Decodable` conformance.

```swift
@DecodablePlus
struct APIResponse {
    let userName: String   // maps to "user_name"
    let createdAt: Date
}
```

---

#### `@EncodablePlus`

Generates `encode(to:)` for `Encodable` conformance.

```swift
@EncodablePlus
struct APIRequest {
    let userName: String
    let email: String
}
```

---

#### `@Defaultable`

Generates a peer type with a static default instance.

```swift
@Defaultable
struct Config {
    var host: String = "localhost"
    var port: Int = 8080
}

// Generated: ConfigDefaults with static default values
```

---

#### `@Flagged(flag:)`

Wraps a function behind a feature flag gate.

```swift
@Flagged(flag: "newDashboard")
func showDashboard() {
    // Only runs if "newDashboard" feature flag is enabled
}

// Generated: flagged_showDashboard() — checks flag before execution
```

---

#### `@DeprecatedPlus(message:)`

Generates a wrapper that prints a deprecation warning at runtime.

```swift
@DeprecatedPlus(message: "Use newMethod() instead")
func oldMethod() {
    // legacy code
}

// Generated: deprecated_oldMethod() — prints warning then runs body
```

---

## Requirements

| Requirement | Minimum |
|---|---|
| Swift | 5.9+ |
| iOS | 17.0+ |
| macOS | 14.0+ |
| tvOS | 17.0+ |
| watchOS | 10.0+ |
| Xcode | 15.0+ |

SwiftMacrosKit depends on [swift-syntax](https://github.com/swiftlang/swift-syntax) 509.0.0+.

---

## Project Structure

```
SwiftMacrosKit/
├── Sources/
│   ├── SwiftMacrosKit/             # Public macro declarations
│   │   ├── Creational/
│   │   ├── Validation/
│   │   ├── Async/
│   │   ├── Persistence/
│   │   ├── Networking/
│   │   ├── Testing/
│   │   ├── SwiftUI/
│   │   ├── Security/
│   │   ├── Logging/
│   │   ├── Patterns/
│   │   └── Utilities/
│   └── SwiftMacrosKitMacros/       # Macro implementations (compiler plugin)
│       ├── Creational/
│       ├── Validation/
│       ├── Async/
│       ├── Persistence/
│       ├── Networking/
│       ├── Testing/
│       ├── SwiftUI/
│       ├── Security/
│       ├── Logging/
│       ├── Patterns/
│       ├── Utilities/
│       └── Shared/                 # Diagnostic helpers & syntax utilities
└── Tests/
    └── SwiftMacrosKitTests/        # 190+ tests with assertMacroExpansion
```

---

## Contributing

Contributions are welcome! Here's how to get started:

1. **Fork** the repository
2. **Create** a feature branch: `git checkout -b feature/my-new-macro`
3. **Add** your macro declaration in the appropriate `Sources/SwiftMacrosKit/<Category>/` file
4. **Implement** the macro in `Sources/SwiftMacrosKitMacros/<Category>/`
5. **Register** it in `SwiftMacrosKitPlugin.swift`
6. **Write tests** using `assertMacroExpansion` (minimum 3 tests per macro)
7. **Submit** a pull request

### Guidelines

- Follow the existing category organization
- Include doc comments with **Before/After** code examples
- Add diagnostics for invalid usage (wrong declaration type, missing arguments, etc.)
- Ensure all tests pass: `swift test`

---

## License

SwiftMacrosKit is released under the **MIT License**. See [LICENSE](LICENSE) for details.

Copyright (c) 2025 Damodar Namala.
