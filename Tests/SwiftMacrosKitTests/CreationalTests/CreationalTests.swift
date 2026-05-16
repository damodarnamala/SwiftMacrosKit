// CreationalTests.swift
// SwiftMacrosKit — Creational Pattern Macro Tests
// Category: [A] Creational Patterns
// Author: SwiftMacrosKit Contributors

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(SwiftMacrosKitMacros)
@testable import SwiftMacrosKitMacros

let creationalMacros: [String: Macro.Type] = [
    "Singleton": SingletonMacro.self,
    "Builder": BuilderMacro.self,
    "Factory": FactoryMacro.self,
    "Prototype": PrototypeMacro.self,
    "FluentBuilder": FluentBuilderMacro.self,
    "StaticFactory": StaticFactoryMacro.self,
    "AutoInit": AutoInitMacro.self,
    "DefaultInit": DefaultInitMacro.self,
    "Pool": PoolMacro.self,
    "Multiton": MultitonMacro.self,
    "Injectable": InjectableMacro.self,
]

// MARK: - Singleton Tests

final class SingletonTests: XCTestCase {
    func testSingletonOnClass() throws {
        assertMacroExpansion(
            """
            @Singleton
            class NetworkManager {
                var baseURL: String = ""
            }
            """,
            expandedSource: """
            class NetworkManager {
                var baseURL: String = ""

                static let shared = NetworkManager()

                private init() {
                }
            }
            """,
            macros: creationalMacros
        )
    }

    func testSingletonOnStructEmitsError() throws {
        assertMacroExpansion(
            """
            @Singleton
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
            macros: creationalMacros
        )
    }

    func testSingletonOnEnumEmitsError() throws {
        assertMacroExpansion(
            """
            @Singleton
            enum MyEnum {
            }
            """,
            expandedSource: """
            enum MyEnum {
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: MacroError.requiresClass.message, line: 1, column: 1)
            ],
            macros: creationalMacros
        )
    }
}

// MARK: - Builder Tests

final class BuilderTests: XCTestCase {
    func testBuilderOnStruct() throws {
        assertMacroExpansion(
            """
            @Builder
            struct User {
                let name: String
                let age: Int
            }
            """,
            expandedSource: """
            struct User {
                let name: String
                let age: Int

                class Builder {
                    private var name: String?
                        private var age: Int?
                        @discardableResult
                    func setName(_ value: String) -> Builder {
                        self.name = value
                        return self
                    }
                            @discardableResult
                    func setAge(_ value: Int) -> Builder {
                        self.age = value
                        return self
                    }
                    func build() -> User {
                        User(name: name!, age: age!)
                    }
                }
            }
            """,
            macros: creationalMacros
        )
    }

    func testBuilderWithOptionalProperty() throws {
        assertMacroExpansion(
            """
            @Builder
            struct Profile {
                let name: String
                let bio: String?
            }
            """,
            expandedSource: """
            struct Profile {
                let name: String
                let bio: String?

                class Builder {
                    private var name: String?
                        private var bio: String?
                        @discardableResult
                    func setName(_ value: String) -> Builder {
                        self.name = value
                        return self
                    }
                            @discardableResult
                    func setBio(_ value: String?) -> Builder {
                        self.bio = value
                        return self
                    }
                    func build() -> Profile {
                        Profile(name: name!, bio: bio)
                    }
                }
            }
            """,
            macros: creationalMacros
        )
    }

    func testBuilderOnEnumEmitsError() throws {
        assertMacroExpansion(
            """
            @Builder
            enum Direction {
                case north
            }
            """,
            expandedSource: """
            enum Direction {
                case north
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: MacroError.requiresStructOrClass.message, line: 1, column: 1)
            ],
            macros: creationalMacros
        )
    }
}

// MARK: - Factory Tests

final class FactoryTests: XCTestCase {
    func testFactoryOnEnum() throws {
        assertMacroExpansion(
            """
            @Factory
            enum Shape {
                case circle(radius: Double)
                case point
            }
            """,
            expandedSource: """
            enum Shape {
                case circle(radius: Double)
                case point

                static func makeCircle(radius: Double) -> Shape {
                    .circle(radius: radius)
                }

                static func makePoint() -> Shape {
                    .point
                }
            }
            """,
            macros: creationalMacros
        )
    }

    func testFactoryOnStructEmitsError() throws {
        assertMacroExpansion(
            """
            @Factory
            struct NotAnEnum {
            }
            """,
            expandedSource: """
            struct NotAnEnum {
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: MacroError.requiresEnum.message, line: 1, column: 1)
            ],
            macros: creationalMacros
        )
    }

    func testFactoryWithMultipleParams() throws {
        assertMacroExpansion(
            """
            @Factory
            enum Shape {
                case rectangle(width: Double, height: Double)
            }
            """,
            expandedSource: """
            enum Shape {
                case rectangle(width: Double, height: Double)

                static func makeRectangle(width: Double, height: Double) -> Shape {
                    .rectangle(width: width, height: height)
                }
            }
            """,
            macros: creationalMacros
        )
    }
}

// MARK: - Prototype Tests

final class PrototypeTests: XCTestCase {
    func testPrototypeOnClass() throws {
        assertMacroExpansion(
            """
            @Prototype
            class Document {
                var title: String = ""
                var content: String = ""
            }
            """,
            expandedSource: """
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
            """,
            macros: creationalMacros
        )
    }

    func testPrototypeOnStructEmitsError() throws {
        assertMacroExpansion(
            """
            @Prototype
            struct Value {
            }
            """,
            expandedSource: """
            struct Value {
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: MacroError.requiresClass.message, line: 1, column: 1)
            ],
            macros: creationalMacros
        )
    }

    func testPrototypeSingleProperty() throws {
        assertMacroExpansion(
            """
            @Prototype
            class Node {
                var value: Int = 0
            }
            """,
            expandedSource: """
            class Node {
                var value: Int = 0

                func copy() -> Node {
                    let clone = Node()
                    clone.value = self.value
                    return clone
                }
            }
            """,
            macros: creationalMacros
        )
    }
}

// MARK: - FluentBuilder Tests

final class FluentBuilderTests: XCTestCase {
    func testFluentBuilderOnStruct() throws {
        assertMacroExpansion(
            """
            @FluentBuilder
            struct Config {
                var host: String = ""
                var port: Int = 8080
            }
            """,
            expandedSource: """
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
            """,
            macros: creationalMacros
        )
    }

    func testFluentBuilderOnEnumEmitsError() throws {
        assertMacroExpansion(
            """
            @FluentBuilder
            enum Direction {
                case north
            }
            """,
            expandedSource: """
            enum Direction {
                case north
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: MacroError.requiresStructOrClass.message, line: 1, column: 1)
            ],
            macros: creationalMacros
        )
    }

    func testFluentBuilderOnClass() throws {
        assertMacroExpansion(
            """
            @FluentBuilder
            class Settings {
                var theme: String = "light"
            }
            """,
            expandedSource: """
            class Settings {
                var theme: String = "light"

                @discardableResult
                func withTheme(_ value: String) -> Self {
                    self.theme = value
                    return self
                }
            }
            """,
            macros: creationalMacros
        )
    }
}

// MARK: - StaticFactory Tests

final class StaticFactoryTests: XCTestCase {
    func testStaticFactoryOnStruct() throws {
        assertMacroExpansion(
            """
            @StaticFactory("create")
            struct Point {
                var x: Double
                var y: Double
            }
            """,
            expandedSource: """
            struct Point {
                var x: Double
                var y: Double

                static func create(x: Double, y: Double) -> Point {
                    Point(x: x, y: y)
                }
            }
            """,
            macros: creationalMacros
        )
    }

    func testStaticFactoryOnClassEmitsError() throws {
        assertMacroExpansion(
            """
            @StaticFactory("make")
            class Nope {
            }
            """,
            expandedSource: """
            class Nope {
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: MacroError.requiresStruct.message, line: 1, column: 1)
            ],
            macros: creationalMacros
        )
    }

    func testStaticFactoryWithDefaults() throws {
        assertMacroExpansion(
            """
            @StaticFactory("origin")
            struct Point {
                var x: Double = 0.0
                var y: Double = 0.0
            }
            """,
            expandedSource: """
            struct Point {
                var x: Double = 0.0
                var y: Double = 0.0

                static func origin(x: Double = 0.0, y: Double = 0.0) -> Point {
                    Point(x: x, y: y)
                }
            }
            """,
            macros: creationalMacros
        )
    }
}

// MARK: - AutoInit Tests

final class AutoInitTests: XCTestCase {
    func testAutoInitOnStruct() throws {
        assertMacroExpansion(
            """
            @AutoInit
            struct User {
                let name: String
                let age: Int
            }
            """,
            expandedSource: """
            struct User {
                let name: String
                let age: Int

                init(name: String, age: Int) {
                    self.name = name
                        self.age = age
                }
            }
            """,
            macros: creationalMacros
        )
    }

    func testAutoInitWithOptional() throws {
        assertMacroExpansion(
            """
            @AutoInit
            struct User {
                let name: String
                var email: String?
            }
            """,
            expandedSource: """
            struct User {
                let name: String
                var email: String?

                init(name: String, email: String? = nil) {
                    self.name = name
                        self.email = email
                }
            }
            """,
            macros: creationalMacros
        )
    }

    func testAutoInitOnEnumEmitsError() throws {
        assertMacroExpansion(
            """
            @AutoInit
            enum Oops {
                case one
            }
            """,
            expandedSource: """
            enum Oops {
                case one
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: MacroError.requiresStructOrClass.message, line: 1, column: 1)
            ],
            macros: creationalMacros
        )
    }
}

// MARK: - DefaultInit Tests

final class DefaultInitTests: XCTestCase {
    func testDefaultInitWithDefaults() throws {
        assertMacroExpansion(
            """
            @DefaultInit
            struct Settings {
                var theme: String = "light"
                var fontSize: Int = 14
            }
            """,
            expandedSource: """
            struct Settings {
                var theme: String = "light"
                var fontSize: Int = 14

                init() {
                    self.theme = "light"
                        self.fontSize = 14
                }
            }
            """,
            macros: creationalMacros
        )
    }

    func testDefaultInitWithOptional() throws {
        assertMacroExpansion(
            """
            @DefaultInit
            struct Config {
                var name: String = "default"
                var extra: String?
            }
            """,
            expandedSource: """
            struct Config {
                var name: String = "default"
                var extra: String?

                init() {
                    self.name = "default"
                        self.extra = nil
                }
            }
            """,
            macros: creationalMacros
        )
    }

    func testDefaultInitOnEnumEmitsError() throws {
        assertMacroExpansion(
            """
            @DefaultInit
            enum Nope {
            }
            """,
            expandedSource: """
            enum Nope {
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: MacroError.requiresStructOrClass.message, line: 1, column: 1)
            ],
            macros: creationalMacros
        )
    }
}

// MARK: - Pool Tests

final class PoolTests: XCTestCase {
    func testPoolOnClass() throws {
        assertMacroExpansion(
            """
            @Pool
            class Connection {
                var isActive = false
            }
            """,
            expandedSource: """
            class Connection {
                var isActive = false

                private static var pool: [Connection] = []

                private static let poolLock = NSLock()

                static func acquire() -> Connection {
                    poolLock.lock()
                    defer {
                        poolLock.unlock()
                    }
                    if let obj = pool.popLast() {
                        return obj
                    }
                    return Connection()
                }

                static func release(_ obj: Connection) {
                    poolLock.lock()
                    defer {
                        poolLock.unlock()
                    }
                    pool.append(obj)
                }
            }
            """,
            macros: creationalMacros
        )
    }

    func testPoolOnStructEmitsError() throws {
        assertMacroExpansion(
            """
            @Pool
            struct Nope {
            }
            """,
            expandedSource: """
            struct Nope {
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: MacroError.requiresClass.message, line: 1, column: 1)
            ],
            macros: creationalMacros
        )
    }

    func testPoolOnEnumEmitsError() throws {
        assertMacroExpansion(
            """
            @Pool
            enum Oops {
            }
            """,
            expandedSource: """
            enum Oops {
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: MacroError.requiresClass.message, line: 1, column: 1)
            ],
            macros: creationalMacros
        )
    }
}

// MARK: - Multiton Tests

final class MultitonTests: XCTestCase {
    func testMultitonOnClass() throws {
        assertMacroExpansion(
            """
            @Multiton
            class Logger {
                var tag: String = ""
            }
            """,
            expandedSource: """
            class Logger {
                var tag: String = ""

                private static var instances: [String: Logger] = [:]

                private static let instancesLock = NSLock()

                static func instance(for key: String) -> Logger {
                    instancesLock.lock()
                    defer {
                        instancesLock.unlock()
                    }
                    if let existing = instances[key] {
                        return existing
                    }
                    let new = Logger()
                    instances[key] = new
                    return new
                }
            }
            """,
            macros: creationalMacros
        )
    }

    func testMultitonOnStructEmitsError() throws {
        assertMacroExpansion(
            """
            @Multiton
            struct Nope {
            }
            """,
            expandedSource: """
            struct Nope {
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: MacroError.requiresClass.message, line: 1, column: 1)
            ],
            macros: creationalMacros
        )
    }

    func testMultitonEmptyClass() throws {
        assertMacroExpansion(
            """
            @Multiton
            class Cache {
            }
            """,
            expandedSource: """
            class Cache {

                private static var instances: [String: Cache] = [:]

                private static let instancesLock = NSLock()

                static func instance(for key: String) -> Cache {
                    instancesLock.lock()
                    defer {
                        instancesLock.unlock()
                    }
                    if let existing = instances[key] {
                        return existing
                    }
                    let new = Cache()
                    instances[key] = new
                    return new
                }
            }
            """,
            macros: creationalMacros
        )
    }
}

// MARK: - Injectable Tests

final class InjectableTests: XCTestCase {
    func testInjectableOnClass() throws {
        assertMacroExpansion(
            """
            @Injectable
            class UserRepo {
                let network: NetworkService
                let db: DatabaseService
            }
            """,
            expandedSource: """
            class UserRepo {
                let network: NetworkService
                let db: DatabaseService

                init(network: NetworkService, db: DatabaseService) {
                    self.network = network
                        self.db = db
                }

                static var dependencies: [Any.Type] {
                    [NetworkService.self, DatabaseService.self]
                }
            }
            """,
            macros: creationalMacros
        )
    }

    func testInjectableOnEnumEmitsError() throws {
        assertMacroExpansion(
            """
            @Injectable
            enum Nope {
            }
            """,
            expandedSource: """
            enum Nope {
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: MacroError.requiresStructOrClass.message, line: 1, column: 1)
            ],
            macros: creationalMacros
        )
    }

    func testInjectableSingleDependency() throws {
        assertMacroExpansion(
            """
            @Injectable
            struct Service {
                let api: APIClient
            }
            """,
            expandedSource: """
            struct Service {
                let api: APIClient

                init(api: APIClient) {
                    self.api = api
                }

                static var dependencies: [Any.Type] {
                    [APIClient.self]
                }
            }
            """,
            macros: creationalMacros
        )
    }
}
#endif
