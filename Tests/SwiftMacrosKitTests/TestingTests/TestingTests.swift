// TestingTests.swift
// SwiftMacrosKit — Testing & Mocking Macro Tests

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(SwiftMacrosKitMacros)
@testable import SwiftMacrosKitMacros

let testingMacros: [String: Macro.Type] = [
    "Mock": MockMacro.self,
    "Spy": SpyMacro.self,
    "Stub": StubMacro.self,
    "TestFixture": TestFixtureMacro.self,
    "Snapshot": SnapshotMacro.self,
    "Benchmark": BenchmarkMacro.self,
    "Given": GivenMacro.self,
    "When": WhenMacro.self,
    "Then": ThenMacro.self,
    "AssertThrows": AssertThrowsMacro.self,
]

// MARK: - Mock Tests

final class MockTests: XCTestCase {
    func testMockOnProtocol() throws {
        assertMacroExpansion(
            """
            @Mock
            protocol DataService {
                func fetchData() -> String
            }
            """,
            expandedSource: """
            protocol DataService {
                func fetchData() -> String
            }

            class MockDataService: DataService {
                var callLog: [String] = []
                var returnValues: [String: Any] = [:]
                    func fetchData()  -> String {
                    callLog.append("fetchData")
                    return returnValues["fetchData"] as! String
                }
            }
            """,
            macros: testingMacros
        )
    }

    func testMockOnClassEmitsError() throws {
        assertMacroExpansion(
            """
            @Mock
            class DataService {
            }
            """,
            expandedSource: """
            class DataService {
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: MacroError.requiresProtocol.message, line: 1, column: 1)
            ],
            macros: testingMacros
        )
    }

    func testMockOnStructEmitsError() throws {
        assertMacroExpansion(
            """
            @Mock
            struct DataService {
            }
            """,
            expandedSource: """
            struct DataService {
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: MacroError.requiresProtocol.message, line: 1, column: 1)
            ],
            macros: testingMacros
        )
    }
}

// MARK: - Stub Tests

final class StubTests: XCTestCase {
    func testStubOnFunction() throws {
        assertMacroExpansion(
            """
            @Stub(returning: 42)
            func compute() -> Int {
                return 0
            }
            """,
            expandedSource: """
            func compute() -> Int {
                return 0
            }

            func stubbed_compute() -> Int {
                return 42
            }
            """,
            macros: testingMacros
        )
    }

    func testStubOnStructEmitsError() throws {
        assertMacroExpansion(
            """
            @Stub(returning: 0)
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
            macros: testingMacros
        )
    }

    func testStubVoidFunction() throws {
        assertMacroExpansion(
            """
            @Stub
            func doWork() {
            }
            """,
            expandedSource: """
            func doWork() {
            }

            func stubbed_doWork() -> Void {
                return ()
            }
            """,
            macros: testingMacros
        )
    }
}

// MARK: - TestFixture Tests

final class TestFixtureTests: XCTestCase {
    func testFixtureOnStruct() throws {
        assertMacroExpansion(
            """
            @TestFixture
            struct User {
                var name: String = ""
                var age: Int = 0
            }
            """,
            expandedSource: """
            struct User {
                var name: String = ""
                var age: Int = 0

                static func fixture(name: String = "", age: Int = 0) -> User {
                    User(name: name, age: age)
                }
            }
            """,
            macros: testingMacros
        )
    }

    func testFixtureOnEnumEmitsError() throws {
        assertMacroExpansion(
            """
            @TestFixture
            enum State {
                case idle
            }
            """,
            expandedSource: """
            enum State {
                case idle
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: MacroError.requiresStructOrClass.message, line: 1, column: 1)
            ],
            macros: testingMacros
        )
    }
}

// MARK: - Benchmark Tests

final class BenchmarkTests: XCTestCase {
    func testBenchmarkOnFunction() throws {
        assertMacroExpansion(
            """
            @Benchmark
            func heavyComputation() {
            }
            """,
            expandedSource: """
            func heavyComputation() {
            }

            func benchmark_heavyComputation() {
                let start = CFAbsoluteTimeGetCurrent()
                for _ in 0 ..< 100 {
                    heavyComputation()
                }
                let elapsed = CFAbsoluteTimeGetCurrent() - start
                print("Benchmark \\("heavyComputation"): \\(elapsed / 100)s avg over 100 iterations")
            }
            """,
            macros: testingMacros
        )
    }

    func testBenchmarkOnStructEmitsError() throws {
        assertMacroExpansion(
            """
            @Benchmark
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
            macros: testingMacros
        )
    }
}

// MARK: - Given/When/Then Tests

final class GivenWhenThenTests: XCTestCase {
    func testGivenExpansion() throws {
        assertMacroExpansion(
            """
            #Given("a user exists") {
                let user = User()
            }
            """,
            expandedSource: """
            {
                print("GIVEN:", "a user exists")

                    let user = User()
            }()
            """,
            macros: testingMacros
        )
    }

    func testWhenExpansion() throws {
        assertMacroExpansion(
            """
            #When("user logs in") {
                login()
            }
            """,
            expandedSource: """
            {
                print("WHEN:", "user logs in")

                    login()
            }()
            """,
            macros: testingMacros
        )
    }

    func testThenExpansion() throws {
        assertMacroExpansion(
            """
            #Then("dashboard is shown") {
                assert(shown)
            }
            """,
            expandedSource: """
            {
                print("THEN:", "dashboard is shown")

                    assert(shown)
            }()
            """,
            macros: testingMacros
        )
    }
}

#endif
