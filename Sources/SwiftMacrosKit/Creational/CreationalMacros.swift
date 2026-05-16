// CreationalMacros.swift
// SwiftMacrosKit — Creational Pattern Macro Declarations
// Category: [A] Creational Patterns
// Author: SwiftMacrosKit Contributors

// MARK: - @Singleton

/// Transforms a class into a thread-safe singleton.
///
/// Generates a `static let shared` instance and a `private init()`.
/// Uses Swift's built-in thread safety for static let initialization.
///
/// - Note: Can only be applied to classes. Emits an error if applied to struct or enum.
///
/// **Before:**
/// ```swift
/// @Singleton
/// class NetworkManager {
///     var baseURL: String = ""
/// }
/// ```
///
/// **After (expanded):**
/// ```swift
/// class NetworkManager {
///     var baseURL: String = ""
///     static let shared = NetworkManager()
///     private init() {}
/// }
/// ```
///
/// **Usage:**
/// ```swift
/// let manager = NetworkManager.shared
/// manager.baseURL = "https://api.example.com"
/// ```
@attached(member, names: named(shared), named(init))
public macro Singleton() = #externalMacro(module: "SwiftMacrosKitMacros", type: "SingletonMacro")

// MARK: - @Builder

/// Generates a Builder inner class for the attached struct or class.
///
/// The builder provides fluent `set` methods for each stored property
/// and a `build()` method that returns an instance of the parent type.
/// Optional properties default to nil; all others require explicit setting.
///
/// **Before:**
/// ```swift
/// @Builder
/// struct User {
///     let name: String
///     let age: Int
///     let email: String?
/// }
/// ```
///
/// **After (expanded):**
/// ```swift
/// struct User {
///     let name: String
///     let age: Int
///     let email: String?
///
///     class Builder {
///         private var name: String?
///         private var age: Int?
///         private var email: String?
///
///         func setName(_ value: String) -> Builder { self.name = value; return self }
///         func setAge(_ value: Int) -> Builder { self.age = value; return self }
///         func setEmail(_ value: String?) -> Builder { self.email = value; return self }
///
///         func build() -> User {
///             User(name: name!, age: age!, email: email)
///         }
///     }
/// }
/// ```
@attached(member, names: named(Builder))
public macro Builder() = #externalMacro(module: "SwiftMacrosKitMacros", type: "BuilderMacro")

// MARK: - @Factory

/// Generates static factory methods for each case of an enum.
///
/// Each enum case becomes a `static func make<CaseName>(...)` method
/// on the enum type.
///
/// **Before:**
/// ```swift
/// @Factory
/// enum Shape {
///     case circle(radius: Double)
///     case rectangle(width: Double, height: Double)
///     case point
/// }
/// ```
///
/// **After (expanded):**
/// ```swift
/// enum Shape {
///     case circle(radius: Double)
///     case rectangle(width: Double, height: Double)
///     case point
///
///     static func makeCircle(radius: Double) -> Shape { .circle(radius: radius) }
///     static func makeRectangle(width: Double, height: Double) -> Shape { .rectangle(width: width, height: height) }
///     static func makePoint() -> Shape { .point }
/// }
/// ```
@attached(member, names: arbitrary)
public macro Factory() = #externalMacro(module: "SwiftMacrosKitMacros", type: "FactoryMacro")

// MARK: - @Prototype

/// Generates a `copy()` method for a class that creates a deep copy.
///
/// All stored properties are copied to a new instance.
///
/// **Before:**
/// ```swift
/// @Prototype
/// class Document {
///     var title: String = ""
///     var content: String = ""
/// }
/// ```
///
/// **After (expanded):**
/// ```swift
/// class Document {
///     var title: String = ""
///     var content: String = ""
///
///     func copy() -> Document {
///         let clone = Document()
///         clone.title = self.title
///         clone.content = self.content
///         return clone
///     }
/// }
/// ```
@attached(member, names: named(copy))
public macro Prototype() = #externalMacro(module: "SwiftMacrosKitMacros", type: "PrototypeMacro")

// MARK: - @FluentBuilder

/// Generates fluent `with<PropertyName>` methods for each stored property.
///
/// Each method returns a modified copy (for structs) or self (for classes).
///
/// **Before:**
/// ```swift
/// @FluentBuilder
/// struct Config {
///     var host: String = ""
///     var port: Int = 8080
/// }
/// ```
///
/// **After (expanded):**
/// ```swift
/// struct Config {
///     var host: String = ""
///     var port: Int = 8080
///
///     func withHost(_ value: String) -> Config {
///         var copy = self
///         copy.host = value
///         return copy
///     }
///     func withPort(_ value: Int) -> Config {
///         var copy = self
///         copy.port = value
///         return copy
///     }
/// }
/// ```
@attached(member, names: arbitrary)
public macro FluentBuilder() = #externalMacro(module: "SwiftMacrosKitMacros", type: "FluentBuilderMacro")

// MARK: - @StaticFactory

/// Generates a named static factory method for a struct.
///
/// - Parameter name: The name of the static factory method.
///
/// **Before:**
/// ```swift
/// @StaticFactory("create")
/// struct Point {
///     var x: Double
///     var y: Double
/// }
/// ```
///
/// **After (expanded):**
/// ```swift
/// struct Point {
///     var x: Double
///     var y: Double
///
///     static func create(x: Double, y: Double) -> Point {
///         Point(x: x, y: y)
///     }
/// }
/// ```
@attached(member, names: arbitrary)
public macro StaticFactory(_ name: String) = #externalMacro(module: "SwiftMacrosKitMacros", type: "StaticFactoryMacro")

// MARK: - @LazyInit

/// Generates thread-safe lazy initialization for a property using a closure.
///
/// Wraps the stored property with a backing storage and locks for thread safety.
///
/// **Before:**
/// ```swift
/// struct Service {
///     @LazyInit({ ExpensiveObject() })
///     var engine: ExpensiveObject
/// }
/// ```
///
/// **After (expanded):**
/// ```swift
/// struct Service {
///     var engine: ExpensiveObject {
///         get {
///             if _engine == nil {
///                 _engine = _engineInit()
///             }
///             return _engine!
///         }
///     }
///     private var _engine: ExpensiveObject?
///     private let _engineInit: () -> ExpensiveObject = { ExpensiveObject() }
/// }
/// ```
@attached(peer, names: prefixed(`_`))
@attached(accessor)
public macro LazyInit(_ initializer: @escaping @autoclosure () -> Any) = #externalMacro(module: "SwiftMacrosKitMacros", type: "LazyInitMacro")

// MARK: - @Pool

/// Generates an object pool for the attached class.
///
/// Provides `acquire()` and `release()` static methods with a pre-allocated pool.
///
/// **Before:**
/// ```swift
/// @Pool
/// class Connection {
///     var isActive = false
/// }
/// ```
///
/// **After (expanded):**
/// ```swift
/// class Connection {
///     var isActive = false
///
///     private static var pool: [Connection] = []
///     private static let poolLock = NSLock()
///
///     static func acquire() -> Connection {
///         poolLock.lock()
///         defer { poolLock.unlock() }
///         if let obj = pool.popLast() { return obj }
///         return Connection()
///     }
///     static func release(_ obj: Connection) {
///         poolLock.lock()
///         defer { poolLock.unlock() }
///         pool.append(obj)
///     }
/// }
/// ```
@attached(member, names: named(pool), named(poolLock), named(acquire), named(release))
public macro Pool() = #externalMacro(module: "SwiftMacrosKitMacros", type: "PoolMacro")

// MARK: - @Multiton

/// Generates a multiton pattern — keyed singletons.
///
/// Provides a `static func instance(for:)` method that returns a shared
/// instance per key.
///
/// **Before:**
/// ```swift
/// @Multiton
/// class Logger {
///     var tag: String = ""
/// }
/// ```
///
/// **After (expanded):**
/// ```swift
/// class Logger {
///     var tag: String = ""
///
///     private static var instances: [String: Logger] = [:]
///     private static let instancesLock = NSLock()
///
///     static func instance(for key: String) -> Logger {
///         instancesLock.lock()
///         defer { instancesLock.unlock() }
///         if let existing = instances[key] { return existing }
///         let new = Logger()
///         instances[key] = new
///         return new
///     }
/// }
/// ```
@attached(member, names: named(instances), named(instancesLock), named(instance))
public macro Multiton() = #externalMacro(module: "SwiftMacrosKitMacros", type: "MultitonMacro")

// MARK: - @Injectable

/// Generates a dependency injection initializer.
///
/// Reads protocol types as parameters and generates an init with all
/// dependencies as parameters plus a static `dependencies` property.
///
/// **Before:**
/// ```swift
/// @Injectable(NetworkService.self, DatabaseService.self)
/// class UserRepository {
///     let network: NetworkService
///     let database: DatabaseService
/// }
/// ```
///
/// **After (expanded):**
/// ```swift
/// class UserRepository {
///     let network: NetworkService
///     let database: DatabaseService
///
///     init(network: NetworkService, database: DatabaseService) {
///         self.network = network
///         self.database = database
///     }
///     static var dependencies: [Any.Type] { [NetworkService.self, DatabaseService.self] }
/// }
/// ```
@attached(member, names: named(init), named(dependencies))
public macro Injectable(_ dependencies: Any.Type...) = #externalMacro(module: "SwiftMacrosKitMacros", type: "InjectableMacro")

// MARK: - @AutoInit

/// Generates a memberwise initializer for all stored properties.
///
/// Respects property access levels and generates appropriate parameter labels.
///
/// **Before:**
/// ```swift
/// @AutoInit
/// struct User {
///     let name: String
///     let age: Int
///     var email: String?
/// }
/// ```
///
/// **After (expanded):**
/// ```swift
/// struct User {
///     let name: String
///     let age: Int
///     var email: String?
///
///     init(name: String, age: Int, email: String? = nil) {
///         self.name = name
///         self.age = age
///         self.email = email
///     }
/// }
/// ```
@attached(member, names: named(init))
public macro AutoInit() = #externalMacro(module: "SwiftMacrosKitMacros", type: "AutoInitMacro")

// MARK: - @DefaultInit

/// Generates an init() using default values specified on each property.
///
/// Properties without defaults cause a compile-time diagnostic.
///
/// **Before:**
/// ```swift
/// @DefaultInit
/// struct Settings {
///     var theme: String = "light"
///     var fontSize: Int = 14
/// }
/// ```
///
/// **After (expanded):**
/// ```swift
/// struct Settings {
///     var theme: String = "light"
///     var fontSize: Int = 14
///
///     init() {
///         self.theme = "light"
///         self.fontSize = 14
///     }
/// }
/// ```
@attached(member, names: named(init))
public macro DefaultInit() = #externalMacro(module: "SwiftMacrosKitMacros", type: "DefaultInitMacro")
