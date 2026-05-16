// PersistenceMacroDeclarations.swift
// SwiftMacrosKit — Persistence & Storage Macro Declarations
// Category: [D] Persistence & Storage
// Author: SwiftMacrosKit Contributors

/// Provides type-safe UserDefaults get/set for a property.
///
/// - Parameters:
///   - key: The UserDefaults key string.
///   - default: Optional default value when key is missing.
///
/// **Usage:** `@UserDefault(key: "theme", default: "light") var theme: String`
@attached(accessor)
public macro UserDefault(key: String, default: Any? = nil) = #externalMacro(module: "SwiftMacrosKitMacros", type: "UserDefaultMacro")

/// Read/write a String/Data property via the Keychain.
///
/// - Parameters:
///   - service: Keychain service identifier.
///   - account: Keychain account identifier.
///
/// **Usage:** `@Keychain(service: "app", account: "token") var token: String?`
@attached(accessor)
public macro Keychain(service: String, account: String) = #externalMacro(module: "SwiftMacrosKitMacros", type: "KeychainMacro")

/// Backs a property with NSUbiquitousKeyValueStore for iCloud sync.
///
/// - Parameter key: The iCloud key-value store key.
///
/// **Usage:** `@CloudSync(key: "prefs") var preferences: String?`
@attached(accessor)
public macro CloudSync(key: String) = #externalMacro(module: "SwiftMacrosKitMacros", type: "CloudSyncMacro")

/// JSON encode/decode a Codable property to a file at a given path.
///
/// - Parameter path: File path for JSON storage.
///
/// **Usage:** `@FileStored(path: "config.json") var config: Config?`
@attached(accessor)
public macro FileStored(path: String) = #externalMacro(module: "SwiftMacrosKitMacros", type: "FileStoredMacro")

/// Generates NSManagedObject subclass boilerplate for Core Data.
///
/// **Usage:** `@CoreDataEntity class User { var name: String; var age: Int }`
@attached(member, names: arbitrary)
public macro CoreDataEntity() = #externalMacro(module: "SwiftMacrosKitMacros", type: "CoreDataEntityMacro")

/// Adds @Model conformance and relationship annotations for SwiftData.
///
/// **Usage:** `@SwiftDataModel class Todo { var title: String; var done: Bool }`
@attached(member, names: named(init))
public macro SwiftDataModel() = #externalMacro(module: "SwiftMacrosKitMacros", type: "SwiftDataModelMacro")

/// In-memory NSCache-backed caching with TTL (time to live).
///
/// - Parameter ttl: Time-to-live in seconds (default: 300).
///
/// **Usage:** `@Cached(ttl: 60) func fetchProfile() -> Profile { ... }`
@attached(peer, names: prefixed(`_cache_`), prefixed(`cached_`), prefixed(`_getCached_`))
public macro Cached(ttl: Double = 300) = #externalMacro(module: "SwiftMacrosKitMacros", type: "CachedMacro")

/// Abstract persistence layer with pluggable backend.
///
/// **Usage:** `@Persisted var settings: AppSettings?`
@attached(accessor)
public macro Persisted() = #externalMacro(module: "SwiftMacrosKitMacros", type: "PersistedMacro")
