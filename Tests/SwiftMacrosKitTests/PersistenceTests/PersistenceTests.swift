// PersistenceTests.swift
// SwiftMacrosKit — Persistence & Storage Macro Tests
// Category: [D] Persistence & Storage
// Author: SwiftMacrosKit Contributors

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(SwiftMacrosKitMacros)
@testable import SwiftMacrosKitMacros

let persistenceMacros: [String: Macro.Type] = [
    "UserDefault": UserDefaultMacro.self,
    "Keychain": KeychainMacro.self,
    "CloudSync": CloudSyncMacro.self,
    "FileStored": FileStoredMacro.self,
    "Persisted": PersistedMacro.self,
    "CoreDataEntity": CoreDataEntityMacro.self,
    "SwiftDataModel": SwiftDataModelMacro.self,
    "Cached": CachedMacro.self,
]

// MARK: - UserDefault Tests

final class UserDefaultTests: XCTestCase {
    func testUserDefaultWithDefault() throws {
        assertMacroExpansion(
            """
            @UserDefault(key: "theme", default: "light") var theme: String
            """,
            expandedSource: """
            var theme: String {
                get {
                    UserDefaults.standard.object(forKey: "theme") as? String ?? "light"
                }
                set {
                    UserDefaults.standard.set(newValue, forKey: "theme")
                }
            }
            """,
            macros: persistenceMacros
        )
    }

    func testUserDefaultOnFunctionEmitsError() throws {
        assertMacroExpansion(
            """
            @UserDefault(key: "k") func doSomething() {
            }
            """,
            expandedSource: """
            func doSomething() {
            }
            """,
            macros: persistenceMacros
        )
    }

    func testUserDefaultWithoutDefault() throws {
        assertMacroExpansion(
            """
            @UserDefault(key: "score") var score: Int
            """,
            expandedSource: """
            var score: Int {
                get {
                    UserDefaults.standard.object(forKey: "score") as? Int
                }
                set {
                    UserDefaults.standard.set(newValue, forKey: "score")
                }
            }
            """,
            macros: persistenceMacros
        )
    }
}

// MARK: - Keychain Tests

final class KeychainTests: XCTestCase {
    func testKeychainOnProperty() throws {
        assertMacroExpansion(
            """
            @Keychain(service: "myapp", account: "token") var token: String?
            """,
            expandedSource: """
            var token: String? {
                get {
                    let query: [String: Any] = [
                        kSecClass as String: kSecClassGenericPassword,
                        kSecAttrService as String: "myapp",
                        kSecAttrAccount as String: "token",
                        kSecReturnData as String: true,
                        kSecMatchLimit as String: kSecMatchLimitOne
                    ]
                    var result: AnyObject?
                    SecItemCopyMatching(query as CFDictionary, &result)
                    return (result as? Data).flatMap {
                        String(data: $0, encoding: .utf8)
                    }
                }
                set {
                    let data = newValue?.data(using: .utf8)
                    let query: [String: Any] = [
                        kSecClass as String: kSecClassGenericPassword,
                        kSecAttrService as String: "myapp",
                        kSecAttrAccount as String: "token"
                    ]
                    SecItemDelete(query as CFDictionary)
                    if let data = data {
                        var attrs = query
                        attrs[kSecValueData as String] = data
                        SecItemAdd(attrs as CFDictionary, nil)
                    }
                }
            }
            """,
            macros: persistenceMacros
        )
    }

    func testKeychainOnFunctionEmitsError() throws {
        assertMacroExpansion(
            """
            @Keychain(service: "s", account: "a") func doSomething() {
            }
            """,
            expandedSource: """
            func doSomething() {
            }
            """,
            macros: persistenceMacros
        )
    }

    func testKeychainDefaultAccount() throws {
        assertMacroExpansion(
            """
            @Keychain(service: "vault") var secret: String?
            """,
            expandedSource: """
            var secret: String? {
                get {
                    let query: [String: Any] = [
                        kSecClass as String: kSecClassGenericPassword,
                        kSecAttrService as String: "vault",
                        kSecAttrAccount as String: "secret",
                        kSecReturnData as String: true,
                        kSecMatchLimit as String: kSecMatchLimitOne
                    ]
                    var result: AnyObject?
                    SecItemCopyMatching(query as CFDictionary, &result)
                    return (result as? Data).flatMap {
                        String(data: $0, encoding: .utf8)
                    }
                }
                set {
                    let data = newValue?.data(using: .utf8)
                    let query: [String: Any] = [
                        kSecClass as String: kSecClassGenericPassword,
                        kSecAttrService as String: "vault",
                        kSecAttrAccount as String: "secret"
                    ]
                    SecItemDelete(query as CFDictionary)
                    if let data = data {
                        var attrs = query
                        attrs[kSecValueData as String] = data
                        SecItemAdd(attrs as CFDictionary, nil)
                    }
                }
            }
            """,
            macros: persistenceMacros
        )
    }
}

// MARK: - CloudSync Tests

final class CloudSyncTests: XCTestCase {
    func testCloudSyncOnProperty() throws {
        assertMacroExpansion(
            """
            @CloudSync(key: "prefs") var preferences: String?
            """,
            expandedSource: """
            var preferences: String? {
                get {
                    NSUbiquitousKeyValueStore.default.object(forKey: "prefs") as? String?
                }
                set {
                    NSUbiquitousKeyValueStore.default.set(newValue, forKey: "prefs")
                    NSUbiquitousKeyValueStore.default.synchronize()
                }
            }
            """,
            macros: persistenceMacros
        )
    }

    func testCloudSyncOnFunctionEmitsError() throws {
        assertMacroExpansion(
            """
            @CloudSync(key: "k") func doSomething() {
            }
            """,
            expandedSource: """
            func doSomething() {
            }
            """,
            macros: persistenceMacros
        )
    }

    func testCloudSyncMissingKeyEmitsError() throws {
        assertMacroExpansion(
            """
            @CloudSync var preferences: String?
            """,
            expandedSource: """
            var preferences: String?
            """,
            diagnostics: [
                DiagnosticSpec(message: MacroError.missingKey.message, line: 1, column: 1)
            ],
            macros: persistenceMacros
        )
    }
}

// MARK: - FileStored Tests

final class FileStoredTests: XCTestCase {
    func testFileStoredOnProperty() throws {
        assertMacroExpansion(
            """
            @FileStored(path: "/data/config.json") var config: Config?
            """,
            expandedSource: """
            var config: Config? {
                get {
                    guard let data = try? Data(contentsOf: URL(fileURLWithPath: "/data/config.json")) else {
                        return nil
                    }
                    return try? JSONDecoder().decode(Config?.self, from: data)
                }
                set {
                    guard let data = try? JSONEncoder().encode(newValue) else {
                        return
                    }
                    try? data.write(to: URL(fileURLWithPath: "/data/config.json"))
                }
            }
            """,
            macros: persistenceMacros
        )
    }

    func testFileStoredOnFunctionEmitsError() throws {
        assertMacroExpansion(
            """
            @FileStored(path: "p") func doSomething() {
            }
            """,
            expandedSource: """
            func doSomething() {
            }
            """,
            macros: persistenceMacros
        )
    }

    func testFileStoredMissingPathEmitsError() throws {
        assertMacroExpansion(
            """
            @FileStored var config: Config?
            """,
            expandedSource: """
            var config: Config?
            """,
            diagnostics: [
                DiagnosticSpec(message: MacroError.missingPath.message, line: 1, column: 1)
            ],
            macros: persistenceMacros
        )
    }
}

// MARK: - Persisted Tests

final class PersistedTests: XCTestCase {
    func testPersistedOnProperty() throws {
        assertMacroExpansion(
            """
            @Persisted var settings: AppSettings?
            """,
            expandedSource: """
            var settings: AppSettings? {
                get {
                    guard let data = UserDefaults.standard.data(forKey: "settings") else {
                        return nil
                    }
                    return try? JSONDecoder().decode(AppSettings?.self, from: data)
                }
                set {
                    let data = try? JSONEncoder().encode(newValue)
                    UserDefaults.standard.set(data, forKey: "settings")
                }
            }
            """,
            macros: persistenceMacros
        )
    }

    func testPersistedOnFunctionEmitsError() throws {
        assertMacroExpansion(
            """
            @Persisted func doSomething() {
            }
            """,
            expandedSource: """
            func doSomething() {
            }
            """,
            macros: persistenceMacros
        )
    }

    func testPersistedDifferentPropertyName() throws {
        assertMacroExpansion(
            """
            @Persisted var profile: UserProfile?
            """,
            expandedSource: """
            var profile: UserProfile? {
                get {
                    guard let data = UserDefaults.standard.data(forKey: "profile") else {
                        return nil
                    }
                    return try? JSONDecoder().decode(UserProfile?.self, from: data)
                }
                set {
                    let data = try? JSONEncoder().encode(newValue)
                    UserDefaults.standard.set(data, forKey: "profile")
                }
            }
            """,
            macros: persistenceMacros
        )
    }
}

// MARK: - CoreDataEntity Tests

final class CoreDataEntityTests: XCTestCase {
    func testCoreDataEntityOnClass() throws {
        assertMacroExpansion(
            """
            @CoreDataEntity
            class User {
                var name: String
                var age: Int
            }
            """,
            expandedSource: """
            class User {
                var name: String
                var age: Int

                @NSManaged var name: String

                @NSManaged var age: Int
            }
            """,
            macros: persistenceMacros
        )
    }

    func testCoreDataEntityOnStructEmitsError() throws {
        assertMacroExpansion(
            """
            @CoreDataEntity
            struct Config {
            }
            """,
            expandedSource: """
            struct Config {
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: MacroError.requiresClass.message, line: 1, column: 1)
            ],
            macros: persistenceMacros
        )
    }

    func testCoreDataEntitySingleProperty() throws {
        assertMacroExpansion(
            """
            @CoreDataEntity
            class Settings {
                var darkMode: Bool
            }
            """,
            expandedSource: """
            class Settings {
                var darkMode: Bool

                @NSManaged var darkMode: Bool
            }
            """,
            macros: persistenceMacros
        )
    }
}

// MARK: - SwiftDataModel Tests

final class SwiftDataModelTests: XCTestCase {
    func testSwiftDataModelOnClass() throws {
        assertMacroExpansion(
            """
            @SwiftDataModel
            class Todo {
                var title: String
                var done: Bool
            }
            """,
            expandedSource: """

            class Todo {
                var title: String
                var done: Bool

                init(title: String, done: Bool) {
                    self.title = title
                        self.done = done
                }
            }
            """,
            macros: persistenceMacros
        )
    }

    func testSwiftDataModelOnStructEmitsError() throws {
        assertMacroExpansion(
            """
            @SwiftDataModel
            struct Config {
            }
            """,
            expandedSource: """
            struct Config {
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: MacroError.requiresClass.message, line: 1, column: 1)
            ],
            macros: persistenceMacros
        )
    }

    func testSwiftDataModelWithOptionalAndDefault() throws {
        assertMacroExpansion(
            """
            @SwiftDataModel
            class Item {
                var title: String
                var count: Int = 0
                var note: String?
            }
            """,
            expandedSource: """

            class Item {
                var title: String
                var count: Int = 0
                var note: String?

                init(title: String, count: Int = 0, note: String? = nil) {
                    self.title = title
                        self.count = count
                        self.note = note
                }
            }
            """,
            macros: persistenceMacros
        )
    }
}

// MARK: - Cached Tests

final class CachedTests: XCTestCase {
    func testCachedOnFunction() throws {
        assertMacroExpansion(
            """
            @Cached(ttl: 60)
            func fetchProfile() -> Profile {
                return loadProfile()
            }
            """,
            expandedSource: """
            func fetchProfile() -> Profile {
                return loadProfile()
            }

            private var _cache_fetchProfile: (value: Profile, date: Date)?

            func cached_fetchProfile() -> Profile? {
                guard let cached = _cache_fetchProfile,
                      Date().timeIntervalSince(cached.date) < 60 else {
                    return nil
                }
                return cached.value
            }
            """,
            macros: persistenceMacros
        )
    }

    func testCachedOnStructEmitsError() throws {
        assertMacroExpansion(
            """
            @Cached(ttl: 60)
            struct Config {
            }
            """,
            expandedSource: """
            struct Config {
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: MacroError.requiresFunction.message, line: 1, column: 1)
            ],
            macros: persistenceMacros
        )
    }

    func testCachedOnProperty() throws {
        assertMacroExpansion(
            """
            @Cached(ttl: 120)
            var profile: Profile
            """,
            expandedSource: """
            var profile: Profile

            private var _cache_profile: (value: Profile, date: Date)?

            private func _getCached_profile() -> Profile? {
                guard let cached = _cache_profile,
                      Date().timeIntervalSince(cached.date) < 120 else {
                    return nil
                }
                return cached.value
            }
            """,
            macros: persistenceMacros
        )
    }
}

#else
final class PersistenceTests: XCTestCase {
    func testMacrosRequirePlugin() throws {
        throw XCTSkip("macros are only supported when running tests for the host platform")
    }
}
#endif
