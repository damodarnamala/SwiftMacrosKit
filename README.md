# SwiftMacrosKit

> A comprehensive collection of **100 production-grade Swift Macros** for Apple ecosystem development.

[![Swift 5.9+](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![Platforms](https://img.shields.io/badge/Platforms-iOS%2017%20|%20macOS%2014%20|%20tvOS%2017%20|%20watchOS%2010-blue.svg)](https://developer.apple.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## Overview

SwiftMacrosKit provides **100 carefully crafted Swift Macros** organized into **11 categories**, covering everything from creational patterns and validation to networking, security, and SwiftUI utilities. Each macro leverages Swift's compile-time macro system via `swift-syntax` to generate boilerplate code, enforce constraints, and improve developer productivity.

## Table of Contents

- [Installation](#installation)
- [A — Creational Patterns (12)](#a-creational-patterns-12-macros)
- [B — Validation & Constraints (10)](#b-validation--constraints-10-macros)
- [C — Async & Concurrency (9)](#c-async--concurrency-9-macros)
- [D — Persistence & Storage (8)](#d-persistence--storage-8-macros)
- [E — Networking (8)](#e-networking-8-macros)
- [F — Testing & Mocking (10)](#f-testing--mocking-10-macros)
- [G — SwiftUI & UI (10)](#g-swiftui--ui-10-macros)
- [H — Security (6)](#h-security-6-macros)
- [I — Logging & Observability (6)](#i-logging--observability-6-macros)
- [J — Design Patterns (10)](#j-design-patterns-10-macros)
- [K — Utilities & DX (10)](#k-utilities--dx-10-macros)
- [Requirements](#requirements)
- [License](#license)

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

---

## [A] Creational Patterns (12 macros)

### `@Singleton`

Transforms a class into a thread-safe singleton. Generates `static let shared` and `private init()`.

```swift
@Singleton
class NetworkManager {
    var baseURL: String = ""
}

// Usage:
let manager = NetworkManager.shared
manager.baseURL = "https://api.example.com"
```

### `@Builder`

Generates a nested `Builder` class with fluent setter methods and a `build()` method.

```swift
@Builder
struct User {
    let name: String
    let age: Int
    let email: String?
}

// Usage:
let user = User.Builder()
    .setName("Alice")
    .setAge(30)
    .setEmail("alice@example.com")
    .build()
```

### `@Factory`

Generates static `make<CaseName>(...)` factory methods for each enum case.

```swift
@Factory
enum Shape {
    case circle(radius: Double)
    case rectangle(width: Double, height: Double)
    case point
}

// Usage:
let shape = Shape.makeCircle(radius: 5.0)
let rect = Shape.makeRectangle(width: 10, height: 20)
let pt = Shape.makePoint()
```

### `@Prototype`

Generates a `copy()` method that creates a deep copy of a class instance.

```swift
@Prototype
class Document {
    var title: String = ""
    var content: String = ""
}

// Usage:
let original = Document()
original.title = "Draft"
let clone = original.copy()  // independent deep copy
```

### `@FluentBuilder`

Generates `with<PropertyName>` methods that return a modified copy.

```swift
@FluentBuilder
struct Config {
    var host: String = ""
    var port: Int = 8080
}

// Usage:
let config = Config()
    .withHost("localhost")
    .withPort(3000)
```

### `@StaticFactory`

Generates a named static factory method for a struct.

```swift
@StaticFactory("create")
struct Point {
    var x: Double
    var y: Double
}

// Usage:
let point = Point.create(x: 10.0, y: 20.0)
```

### `@AutoInit`

Generates a memberwise initializer for all stored properties.

```swift
@AutoInit
struct User {
    let name: String
    let age: Int
    var email: String?
}

// Usage:
let user = User(name: "Bob", age: 25, email: nil)
```

### `@DefaultInit`

Generates an `init()` that uses each property's default value.

```swift
@DefaultInit
struct Settings {
    var theme: String = "light"
    var fontSize: Int = 14
}

// Usage:
let settings = Settings()  // theme = "light", fontSize = 14
```

### `@LazyInit`

Generates thread-safe lazy initialization with a backing storage property.

```swift
struct Service {
    @LazyInit({ ExpensiveObject() })
    var engine: ExpensiveObject
}

// Usage:
var svc = Service()
let obj = svc.engine  // initialized on first access
```

### `@Pool`

Generates an object pool with `acquire()` and `release()` static methods.

```swift
@Pool
class Connection {
    var isActive = false
}

// Usage:
let conn = Connection.acquire()
conn.isActive = true
// ... use connection ...
Connection.release(conn)  // return to pool
```

### `@Multiton`

Generates a keyed singleton — `static func instance(for:)` returns a shared instance per key.

```swift
@Multiton
class Logger {
    var tag: String = ""
}

// Usage:
let networkLogger = Logger.instance(for: "network")
let dbLogger = Logger.instance(for: "database")
networkLogger.tag = "NET"
// Logger.instance(for: "network") always returns the same instance
```

### `@Injectable`

Generates a dependency injection initializer and a `static var dependencies` list.

```swift
@Injectable(NetworkService.self, DatabaseService.self)
class UserRepository {
    let network: NetworkService
    let database: DatabaseService
}

// Usage:
let repo = UserRepository(
    network: NetworkServiceImpl(),
    database: DatabaseServiceImpl()
)
print(UserRepository.dependencies)  // [NetworkService.self, DatabaseService.self]
```

---

## [B] Validation & Constraints (10 macros)

### `@Validated`

Validates a property value using a predicate closure. Reverts to `oldValue` if the predicate returns `false`.

```swift
struct Counter {
    @Validated({ $0 > 0 })
    var count: Int = 1
}

// Usage:
var c = Counter()
c.count = 5   // accepted
c.count = -1  // rejected, stays 5
```

### `@NonEmpty`

Rejects empty `String` or `Array` values, reverting to `oldValue`.

```swift
struct Profile {
    @NonEmpty var name: String = "Anonymous"
}

// Usage:
var p = Profile()
p.name = "Alice"  // accepted
p.name = ""       // rejected, stays "Alice"
```

### `@Clamped`

Clamps a numeric value to a `min...max` range on assignment.

```swift
struct Slider {
    @Clamped(min: 0, max: 100)
    var percentage: Int = 50
}

// Usage:
var s = Slider()
s.percentage = 150  // clamped to 100
s.percentage = -10  // clamped to 0
```

### `@Regex`

Validates a `String` property against a regex pattern. Reverts on mismatch.

```swift
struct Form {
    @Regex("^[0-9]+$")
    var zipCode: String = "12345"
}

// Usage:
var f = Form()
f.zipCode = "67890"  // accepted
f.zipCode = "abcde"  // rejected, stays "67890"
```

### `@Email`

Validates that a `String` contains a valid email format.

```swift
struct Account {
    @Email var email: String = "user@example.com"
}

// Usage:
var a = Account()
a.email = "alice@gmail.com"  // accepted
a.email = "not-an-email"     // rejected
```

### `@URL`

Validates that a `String` contains a valid URL.

```swift
struct Bookmark {
    @URL var link: String = "https://example.com"
}

// Usage:
var b = Bookmark()
b.link = "https://swift.org"  // accepted
b.link = "not a url"          // rejected
```

### `@MinLength`

Enforces a minimum length on a `String` or `Array` property.

```swift
struct Registration {
    @MinLength(3)
    var username: String = "abc"
}

// Usage:
var r = Registration()
r.username = "Al"       // rejected (length 2 < 3)
r.username = "Alice"    // accepted
```

### `@MaxLength`

Enforces a maximum length, truncating if exceeded.

```swift
struct Post {
    @MaxLength(280)
    var body: String = ""
}

// Usage:
var post = Post()
post.body = String(repeating: "a", count: 500)  // truncated to 280 chars
```

### `@NotNil`

Traps with a fatal error if an optional property is set to `nil`.

```swift
struct Required {
    @NotNil var value: String? = "hello"
}

// Usage:
var r = Required()
r.value = "world"  // fine
r.value = nil      // fatal error: "value must not be nil"
```

### `@Range`

Asserts that a `Comparable` value is within a range using `precondition`.

```swift
struct Game {
    @Range(min: 1, max: 10)
    var level: Int = 5
}

// Usage:
var g = Game()
g.level = 7   // accepted
g.level = 15  // precondition failure
```

---

## [C] Async & Concurrency (9 macros)

### `@Retry`

Generates a `_retrying_<name>` peer function that retries on failure.

```swift
class API {
    @Retry(attempts: 3, delay: 2.0)
    func fetchData() async throws -> Data {
        try await URLSession.shared.data(from: url).0
    }
}

// Usage:
let data = try await api._retrying_fetchData()  // retries up to 3 times
```

### `@Timeout`

Generates a `_withTimeout_<name>` peer that cancels after a duration.

```swift
class Downloader {
    @Timeout(seconds: 30)
    func download() async throws -> Data {
        try await longRunningTask()
    }
}

// Usage:
let data = try await downloader._withTimeout_download()  // cancels after 30s
```

### `@Debounce`

Generates a `debounced_<name>` function that delays execution, cancelling previous calls.

```swift
class SearchController {
    @Debounce(seconds: 0.3)
    func search() {
        performSearch()
    }
}

// Usage:
controller.debounced_search()  // only fires 0.3s after last call
```

### `@Throttle`

Generates a `throttled_<name>` function that ignores calls within a time window.

```swift
class Analytics {
    @Throttle(seconds: 1.0)
    func sendEvent() {
        track()
    }
}

// Usage:
analytics.throttled_sendEvent()  // at most once per second
```

### `@BackgroundActor`

Generates a `BackgroundActor` global actor declaration for background execution.

```swift
class Processor {
    @BackgroundActor
    func processData() {
        heavyCompute()
    }
}

// Generated peer:
// @globalActor actor BackgroundActor { static let shared = BackgroundActor() }
```

### `@AsyncCached`

Generates `cached_<name>` (returns cached or fetches) and `invalidate_<name>` (clears cache).

```swift
class ConfigLoader {
    @AsyncCached
    func loadConfig() async throws -> Config {
        try await fetchFromServer()
    }
}

// Usage:
let config = try await loader.cached_loadConfig()   // fetches once, then caches
loader.invalidate_loadConfig()                       // clears cache
```

### `@RateLimit`

Generates a `rateLimited_<name>` function that throws when call limit is exceeded.

```swift
class APIClient {
    @RateLimit(calls: 10, per: 60)
    func apiCall() {
        makeRequest()
    }
}

// Usage:
client.rateLimited_apiCall()  // throws after 10 calls within 60 seconds
```

### `@Concurrent`

Generates a `concurrent_<name>` peer that runs the function body via TaskGroup.

```swift
class ImageProcessor {
    @Concurrent
    func process(_ items: [Image]) -> [Result] {
        items.map { transform($0) }
    }
}

// Usage:
let results = await processor.concurrent_process(images)
```

### `@Serial`

Adds a serial task queue with `_serialQueue` and `enqueue(_:)` method.

```swift
@Serial
class Worker {
    func doWork() { }
}

// Usage:
let worker = Worker()
worker.enqueue {
    await worker.doWork()
}
// Tasks execute in FIFO order
```

---

## [D] Persistence & Storage (8 macros)

### `@UserDefault`

Reads/writes a property via `UserDefaults` with a given key and optional default.

```swift
struct Settings {
    @UserDefault(key: "theme", default: "light")
    var theme: String

    @UserDefault(key: "launchCount", default: 0)
    var launchCount: Int
}

// Usage:
var settings = Settings()
settings.theme = "dark"         // saved to UserDefaults
print(settings.theme)           // reads from UserDefaults
```

### `@Keychain`

Reads/writes a `String` property via the iOS/macOS Keychain.

```swift
struct Credentials {
    @Keychain(service: "com.myapp", account: "authToken")
    var token: String?
}

// Usage:
var creds = Credentials()
creds.token = "secret-jwt-token"  // stored in Keychain
print(creds.token ?? "none")      // read from Keychain
```

### `@CloudSync`

Backs a property with `NSUbiquitousKeyValueStore` for iCloud key-value sync.

```swift
struct Preferences {
    @CloudSync(key: "favoriteColor")
    var favoriteColor: String?
}

// Usage:
var prefs = Preferences()
prefs.favoriteColor = "blue"  // synced across devices via iCloud
```

### `@FileStored`

JSON encodes/decodes a `Codable` property to a file.

```swift
struct AppState {
    @FileStored(path: "state.json")
    var config: Config?
}

// Usage:
var state = AppState()
state.config = Config(apiKey: "abc")  // written to state.json
let loaded = state.config             // read from state.json
```

### `@Persisted`

Abstract persistence layer — stores/retrieves via a pluggable backend.

```swift
struct Cache {
    @Persisted var lastSync: String?
}

// Usage:
var cache = Cache()
cache.lastSync = "2025-05-16"  // persisted via backend
```

### `@CoreDataEntity`

Generates Core Data `@NSManaged` property declarations for a class.

```swift
@CoreDataEntity
class User {
    var name: String = ""
    var age: Int = 0
}

// Generates @NSManaged versions of each property
```

### `@SwiftDataModel`

Generates a memberwise `init` for SwiftData `@Model` classes.

```swift
@SwiftDataModel
class Todo {
    var title: String = ""
    var isDone: Bool = false
}

// Usage:
let todo = Todo(title: "Buy milk", isDone: false)
```

### `@Cached`

Generates an in-memory `NSCache`-backed wrapper with TTL (time to live).

```swift
class ProfileService {
    @Cached(ttl: 60)
    func fetchProfile() -> Profile {
        loadFromNetwork()
    }
}

// Usage:
let profile = service.cached_fetchProfile()  // cached for 60 seconds
```

---

## [E] Networking (8 macros)

### `@Endpoint`

Generates an `asURLRequest()` method from struct properties representing query params.

```swift
@Endpoint(path: "/users", method: "GET")
struct FetchUsers {
    var page: Int = 1
    var limit: Int = 20
}

// Usage:
let request = FetchUsers(page: 2, limit: 50)
let urlRequest = request.asURLRequest()
```

### `@GET`

Shorthand for `@Endpoint` with the GET method.

```swift
@GET("/posts")
struct FetchPosts {
    var tag: String = "swift"
}

// Usage:
let req = FetchPosts(tag: "macros").asURLRequest()
```

### `@POST`

Shorthand for `@Endpoint` with the POST method and JSON body encoding.

```swift
@POST("/users")
struct CreateUser {
    var name: String = ""
    var email: String = ""
}

// Usage:
let req = CreateUser(name: "Alice", email: "a@b.com").asURLRequest()
// Body is JSON-encoded
```

### `@Headers`

Generates an `applyHeaders(to:)` method that sets custom HTTP headers.

```swift
@Headers(["Accept": "application/json", "X-API-Version": "2"])
struct APIRequest {
    var endpoint: String = ""
}

// Usage:
var urlRequest = URLRequest(url: url)
let api = APIRequest()
api.applyHeaders(to: &urlRequest)
```

### `@Bearer`

Generates an `applyBearerToken(to:)` method for Authorization headers.

```swift
@Bearer
struct AuthenticatedRequest {
    var token: String = ""
}

// Usage:
var req = URLRequest(url: url)
let auth = AuthenticatedRequest(token: "my-jwt")
auth.applyBearerToken(to: &req)
// Sets "Authorization: Bearer my-jwt"
```

### `@Multipart`

Generates an `asMultipartRequest()` method with multipart/form-data encoding.

```swift
@Multipart
struct UploadRequest {
    var file: Data = Data()
    var fileName: String = ""
}

// Usage:
let upload = UploadRequest(file: imageData, fileName: "photo.jpg")
let req = upload.asMultipartRequest()
```

### `@MockResponse`

Generates a `mockData` property returning a mock HTTP response for testing.

```swift
@MockResponse(json: "{\"id\": 1, \"name\": \"Alice\"}", statusCode: 200)
struct UserEndpoint {
    var userId: Int = 0
}

// Usage in tests:
let mock = UserEndpoint()
let data = mock.mockData  // returns the JSON as Data
```

### `@QueryParam`

Marks a property as a URL query parameter (accessor marker).

```swift
struct SearchRequest {
    @QueryParam var query: String = ""
    @QueryParam var page: Int = 1
}

// Usage:
var req = SearchRequest()
req.query = "swift macros"
req.page = 2
```

---

## [F] Testing & Mocking (10 macros)

### `@Mock`

Auto-generates a `Mock<ProtocolName>` class implementing all protocol methods with call recording.

```swift
@Mock
protocol DataService {
    func fetchUser() -> User
    func saveUser(_ user: User)
}

// Usage in tests:
let mock = MockDataService()
mock.fetchUserReturn = User(name: "Test")
let user = mock.fetchUser()
print(mock.fetchUserCallCount)  // 1
```

### `@Spy`

Generates a `Spy<ClassName>` subclass that records all method invocations.

```swift
@Spy
class UserService {
    func getUser() -> String { "real" }
}

// Usage in tests:
let spy = SpyUserService()
_ = spy.getUser()
print(spy.getUserCallCount)  // 1
```

### `@Stub`

Generates a `stubbed_<name>` function that always returns a fixed value.

```swift
class API {
    @Stub(returning: "test-data")
    func getData() -> String {
        realNetworkCall()
    }
}

// Usage in tests:
let result = api.stubbed_getData()  // always returns "test-data"
```

### `@TestFixture`

Generates a `static func fixture()` factory method with default values.

```swift
@TestFixture
struct User {
    let name: String
    let age: Int
}

// Usage in tests:
let user = User.fixture()  // name: "", age: 0
```

### `@Snapshot`

Generates a snapshot test helper peer for a SwiftUI view.

```swift
@Snapshot
struct ProfileCard: View {
    var body: some View {
        Text("Hello")
    }
}

// Generates a peer snapshot helper for visual regression tests
```

### `@Benchmark`

Generates a `benchmark_<name>` function that measures execution time.

```swift
class Sorter {
    @Benchmark
    func sort(_ array: [Int]) -> [Int] {
        array.sorted()
    }
}

// Usage:
let result = sorter.benchmark_sort([3, 1, 2])
// Prints: "benchmark_sort took X.XXs (100 iterations)"
```

### `#Given` / `#When` / `#Then`

BDD-style test organization macros for readable test scenarios.

```swift
func testUserLogin() {
    #Given("a valid user") {
        setupUser()
    }

    #When("the user logs in") {
        login()
    }

    #Then("the user is authenticated") {
        XCTAssertTrue(isAuthenticated)
    }
}

// Each prints its step name and executes the closure
```

### `#AssertThrows`

Asserts that an async expression throws a specific error type.

```swift
func testNetworkError() async {
    #AssertThrows(NetworkError.self) {
        try await api.fetchInvalidEndpoint()
    }
}
```

---

## [G] SwiftUI & UI (10 macros)

### `@PreviewProvider`

Generates `_previewContent` with common device previews.

```swift
@PreviewProvider
struct ContentView: View {
    var body: some View {
        Text("Hello")
    }
}

// Generates preview content for iPhone SE, iPhone 15 Pro, iPad
```

### `@ViewState`

Extracts `@State` properties into a nested `ViewState` struct.

```swift
@ViewState
struct CounterView: View {
    @State var count: Int = 0
    @State var label: String = ""

    var body: some View { Text("\(count)") }
}

// Generates:
// struct ViewState { var count: Int; var label: String }
```

### `@StyleSheet`

Generates static design token constants (spacing, corner radius, etc.).

```swift
@StyleSheet
struct AppStyles { }

// Generates:
// static let spacing: CGFloat = 8.0
// static let cornerRadius: CGFloat = 12.0
// static let primaryColor: String = "#007AFF"
```

### `@Themed`

Injects an `@Environment(\.colorScheme)` property.

```swift
@Themed
struct ThemedView: View {
    var body: some View {
        Text("Hello")
            .foregroundColor(colorScheme == .dark ? .white : .black)
    }
}

// Generates: @Environment(\.colorScheme) var colorScheme
```

### `@AnimatablePlus`

Generates `animatableData` conformance for `Animatable` types.

```swift
@AnimatablePlus
struct AnimatedShape {
    var progress: Double = 0.0
}

// Generates:
// var animatableData: Double {
//     get { progress }
//     set { progress = newValue }
// }
```

### `@OrientationAware`

Injects horizontal/vertical size class environment values and orientation helpers.

```swift
@OrientationAware
struct ResponsiveView: View {
    var body: some View {
        if isLandscape { HStack { content } }
        else { VStack { content } }
    }
}

// Generates:
// @Environment(\.horizontalSizeClass) var horizontalSizeClass
// @Environment(\.verticalSizeClass) var verticalSizeClass
// var isLandscape: Bool { ... }
// var isPortrait: Bool { ... }
```

### `@SafeArea`

Injects safe area insets reader into a view.

```swift
@SafeArea
struct FullScreenView: View {
    var body: some View {
        Text("Full Screen")
    }
}

// Generates a SafeAreaReader helper
```

### `@BindablePlus`

Accessor-based bindable property marker for Observable classes.

```swift
struct MyView: View {
    @BindablePlus var viewModel: MyViewModel

    var body: some View {
        TextField("Name", text: $viewModel.name)
    }
}
```

### `@Accessible`

Generates a peer with accessibility label and hint.

```swift
@Accessible(label: "Submit Button", hint: "Double tap to submit the form")
struct SubmitButton: View {
    var body: some View {
        Button("Submit") { }
    }
}
```

### `@HapticFeedback`

Generates a `<name>WithHaptic` peer that triggers haptic feedback before executing.

```swift
class ViewController {
    @HapticFeedback(style: ".heavy")
    func onTap() {
        handleTap()
    }
}

// Usage:
controller.onTapWithHaptic()  // triggers haptic then runs onTap
```

---

## [H] Security (6 macros)

### `@Encrypted`

Encrypts on `set`, decrypts on `get` using CryptoKit AES.

```swift
struct Vault {
    @Encrypted(algorithm: .aes)
    var secret: String = ""
}

// Usage:
var vault = Vault()
vault.secret = "my-password"      // stored encrypted
print(vault.secret)                // decrypted on read
```

### `@Hashed`

One-way SHA256 hash on assignment.

```swift
struct Auth {
    @Hashed(using: .sha256)
    var password: String = ""
}

// Usage:
var auth = Auth()
auth.password = "mypassword"       // stored as SHA256 hash
// auth.password == "5e884898da..."
```

### `@Redacted`

Marks a property for redaction in logs and descriptions. Shows "***" instead of actual value.

```swift
struct Identity {
    @Redacted var ssn: String = ""
}

// Usage:
var id = Identity()
id.ssn = "123-45-6789"
// In logs/descriptions: ssn = "***"
```

### `@Sanitized`

Strips HTML/script tags and trims whitespace on assignment.

```swift
struct Comment {
    @Sanitized var body: String = ""
}

// Usage:
var comment = Comment()
comment.body = "<script>alert('xss')</script>Hello"
print(comment.body)  // "Hello"
```

### `@BiometricGated`

Generates a `biometricGated_<name>` peer that requires Face ID / Touch ID before execution.

```swift
class SecureVault {
    @BiometricGated
    func showSecretData() {
        displaySecrets()
    }
}

// Usage:
vault.biometricGated_showSecretData()
// Prompts biometric auth, only runs if successful
```

### `@SecureEnclave`

Stores/retrieves data using Secure Enclave via CryptoKit.

```swift
struct KeyStore {
    @SecureEnclave var sensitiveData: Data = Data()
}

// Usage:
var ks = KeyStore()
ks.sensitiveData = secretKey  // protected by Secure Enclave
```

---

## [I] Logging & Observability (6 macros)

### `@Logged`

Generates a `logged_<name>` peer that logs function entry (with args) and exit (with result) via OSLog.

```swift
class DataProcessor {
    @Logged(level: .info)
    func processData() -> Result {
        doWork()
    }
}

// Usage:
let result = processor.logged_processData()
// Logs: "[INFO] ▶ processData()"
// Logs: "[INFO] ◀ processData() -> <result>"
```

### `@Traced`

Generates a `traced_<name>` peer with Instruments signpost markers.

```swift
class Renderer {
    @Traced
    func render() async throws {
        await drawFrame()
    }
}

// Usage:
try await renderer.traced_render()
// Shows begin/end signpost intervals in Instruments
```

### `@Measured`

Generates a `measured_<name>` peer that logs execution time.

```swift
class Sorter {
    @Measured
    func sort(_ items: [Int]) -> [Int] {
        items.sorted()
    }
}

// Usage:
let sorted = sorter.measured_sort([3, 1, 2])
// Prints: "measured_sort took 0.0012s"
```

### `@OSLogged`

Generates a `private static let logger` property using os.Logger.

```swift
@OSLogged(subsystem: "com.myapp", category: "networking")
class APIClient {
    func fetch() {
        Self.logger.info("Fetching data...")
    }
}

// Generates:
// private static let logger = Logger(subsystem: "com.myapp", category: "networking")
```

### `@Crashlytic`

Generates a `safe_<name>` peer that wraps in do/catch and records errors as non-fatal.

```swift
class FileManager {
    @Crashlytic
    func loadFile() throws {
        try readFromDisk()
    }
}

// Usage:
fileManager.safe_loadFile()
// If throws, records error via Crashlytics instead of crashing
```

### `@Analytics`

Generates a `tracked_<name>` peer that fires an analytics event.

```swift
class SettingsVC {
    @Analytics(event: "settings_opened")
    func viewDidAppear() {
        loadSettings()
    }
}

// Usage:
controller.tracked_viewDidAppear()
// Fires "settings_opened" event, then runs original function
```

---

## [J] Design Patterns (10 macros)

### `@Observer`

Generates observer pattern infrastructure: `observers` dictionary, `addObserver`, `removeObserver`, `notifyObservers`.

```swift
@Observer
class EventEmitter {
    var value: Int = 0

    func update(_ newValue: Int) {
        value = newValue
        notifyObservers(newValue)
    }
}

// Usage:
let emitter = EventEmitter()
emitter.addObserver(self) { event in
    print("Received: \(event)")
}
emitter.update(42)  // prints "Received: 42"
emitter.removeObserver(self)
```

### `@Command`

Generates `execute()` and `undo()` method stubs for the Command pattern.

```swift
@Command
struct SaveCommand {
    var document: Document
}

// Usage:
var cmd = SaveCommand(document: doc)
cmd.execute()  // perform save
cmd.undo()     // revert save
```

### `@Decorator`

Generates a `wrapped` property for the Decorator pattern.

```swift
@Decorator
protocol Drawable {
    func draw()
}

// Generates: var wrapped: Drawable?
// Override to intercept calls and delegate to wrapped
```

### `@Composite`

Adds `children` array, `add(_:)`, and `remove(at:)` for tree structures.

```swift
@Composite
class UIComponent {
    var name: String = ""
}

// Usage:
let root = UIComponent()
let child1 = UIComponent()
root.add(child1)
root.remove(at: 0)
print(root.children.count)  // 0
```

### `@Strategy`

Generates a peer protocol and context class for swappable algorithms.

```swift
@Strategy
struct SortingStrategy {
    func sort(_ items: [Int]) -> [Int] {
        items.sorted()
    }
}

// Generates:
// protocol SortingStrategyProtocol { func sort(_ items: [Int]) -> [Int] }
// class SortingStrategyContext {
//     var strategy: SortingStrategyProtocol
//     func sort(_ items: [Int]) -> [Int] { strategy.sort(items) }
// }
```

### `@StateMachine`

Adds a `State` enum, `currentState` property, and `transition(to:)` method with validation.

```swift
@StateMachine(states: "idle, loading, loaded, error")
class ViewModel {
    func fetchData() {
        transition(to: .loading)
        // ... load data ...
        transition(to: .loaded)
    }
}

// Usage:
let vm = ViewModel()
print(vm.currentState)   // .idle
vm.transition(to: .loading)
print(vm.currentState)   // .loading
```

### `#EventBus`

Generates a type-safe publish/subscribe event bus.

```swift
#EventBus(events: "userLoggedIn, dataLoaded, errorOccurred")

// Generates an EventBus class with:
// - subscribe(to:handler:) for each event
// - publish(event:data:) to broadcast
// - shared singleton instance
```

### `@Pipeline`

Generates a `<Name>Runner` peer with chained stage execution.

```swift
@Pipeline
struct ImagePipeline {
    func resize(_ image: Image) -> Image { ... }
    func filter(_ image: Image) -> Image { ... }
}

// Usage:
let runner = ImagePipelineRunner()
let result = runner.run(inputImage)  // resize -> filter -> output
```

### `@CQRS`

Splits a struct into `CommandModel` and `QueryModel` nested types.

```swift
@CQRS
struct UserService {
    var name: String = ""
    var email: String = ""
}

// Generates:
// struct CommandModel { var name: String; var email: String }
// struct QueryModel { let name: String; let email: String }
```

### `@Repository`

Generates a `<Name>RepositoryProtocol` and `<Name>Repository` implementation.

```swift
@Repository
struct User {
    let id: String
    let name: String
}

// Generates:
// protocol UserRepositoryProtocol {
//     func get(id: String) -> User?
//     func save(_ item: User)
//     func delete(id: String)
//     func getAll() -> [User]
// }
// class UserRepository: UserRepositoryProtocol { ... }
```

---

## [K] Utilities & DX (10 macros)

### `@EquatablePlus`

Generates `==` operator for classes (which don't get auto-synthesized Equatable).

```swift
@EquatablePlus
class User {
    var name: String = ""
    var age: Int = 0
}

// Usage:
let a = User(); a.name = "Alice"; a.age = 30
let b = User(); b.name = "Alice"; b.age = 30
print(a == b)  // true
```

### `@ComparablePlus`

Generates `<` operator using a specified key property.

```swift
@ComparablePlus(key: "age")
struct Person {
    var name: String = ""
    var age: Int = 0
}

// Usage:
let people = [Person(age: 30), Person(age: 20)]
let sorted = people.sorted()  // sorted by age
```

### `@Copyable`

Generates a `copy(...)` method for modifying specific properties.

```swift
@Copyable
struct Config {
    var host: String = ""
    var port: Int = 8080
}

// Usage:
let base = Config(host: "localhost", port: 3000)
let copy = base.copy(port: 4000)  // host stays "localhost"
```

### `@StringConvertible`

Generates a human-readable `description` property listing all stored properties.

```swift
@StringConvertible
struct User {
    var name: String = "Alice"
    var age: Int = 30
}

// Usage:
print(User())  // "User(name: Alice, age: 30)"
```

### `@CaseIterablePlus`

Adds an `allCases` array for enums with associated values (which can't use `CaseIterable`).

```swift
@CaseIterablePlus
enum Theme {
    case light
    case dark
    case custom(String)
}

// Usage:
print(Theme.allCases)  // [.light, .dark]
```

### `@Defaultable`

Generates a `<Name>Defaults` peer struct with a static `default` instance.

```swift
@Defaultable
struct Config {
    var host: String = "localhost"
    var port: Int = 8080
}

// Usage:
let defaults = ConfigDefaults.default  // host: "localhost", port: 8080
```

### `@DecodablePlus`

Generates `CodingKeys` enum and custom `init(from decoder:)`.

```swift
@DecodablePlus
struct APIResponse {
    var userId: Int = 0
    var userName: String = ""
}

// Generates:
// enum CodingKeys: String, CodingKey { case userId, userName }
// init(from decoder: Decoder) throws { ... }
```

### `@EncodablePlus`

Generates custom `encode(to encoder:)` method.

```swift
@EncodablePlus
struct APIRequest {
    var query: String = ""
    var page: Int = 1
}

// Generates:
// func encode(to encoder: Encoder) throws {
//     var container = encoder.container(keyedBy: CodingKeys.self)
//     try container.encode(query, forKey: .query)
//     try container.encode(page, forKey: .page)
// }
```

### `@Flagged`

Generates a `flagged_<name>` peer that only runs if a feature flag is enabled.

```swift
class Dashboard {
    @Flagged(flag: "newUI")
    func showDashboard() {
        renderNewUI()
    }
}

// Usage:
dashboard.flagged_showDashboard()
// Only executes if FeatureFlags.isEnabled("newUI") returns true
```

### `@DeprecatedPlus`

Generates a `deprecated_<name>` peer that prints a runtime deprecation warning.

```swift
class API {
    @DeprecatedPlus(message: "Use fetchV2() instead")
    func fetch() {
        oldImplementation()
    }
}

// Usage:
api.deprecated_fetch()
// Prints: "⚠️ deprecated: Use fetchV2() instead"
// Then runs the original function
```

---

## Requirements

- Swift 5.9+
- iOS 17+ / macOS 14+ / tvOS 17+ / watchOS 10+
- Xcode 15+

## License

MIT License. See [LICENSE](LICENSE) for details.
