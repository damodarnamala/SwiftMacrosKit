// LoggingTests.swift
// SwiftMacrosKit — Logging & Observability Macro Tests

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(SwiftMacrosKitMacros)
@testable import SwiftMacrosKitMacros

let loggingMacros: [String: Macro.Type] = [
    "Logged": LoggedMacro.self,
    "Traced": TracedMacro.self,
    "Measured": MeasuredMacro.self,
    "OSLogged": OSLoggedMacro.self,
    "Crashlytic": CrashlyticMacro.self,
    "Analytics": AnalyticsMacro.self,
]

// MARK: - Measured Tests

final class MeasuredTests: XCTestCase {
    func testMeasuredOnVoidFunction() throws {
        assertMacroExpansion(
            """
            @Measured
            func doWork() {
            }
            """,
            expandedSource: """
            func doWork() {
            }

            func measured_doWork() {
                let start = CFAbsoluteTimeGetCurrent()
                doWork()
                let elapsed = CFAbsoluteTimeGetCurrent() - start
                print("[Measured] doWork took \\(elapsed)s")
            }
            """,
            macros: loggingMacros
        )
    }

    func testMeasuredOnReturningFunction() throws {
        assertMacroExpansion(
            """
            @Measured
            func compute() -> Int {
                return 42
            }
            """,
            expandedSource: """
            func compute() -> Int {
                return 42
            }

            func measured_compute() -> Int {
                let start = CFAbsoluteTimeGetCurrent()
                let result = compute()
                let elapsed = CFAbsoluteTimeGetCurrent() - start
                print("[Measured] compute took \\(elapsed)s")
                return result
            }
            """,
            macros: loggingMacros
        )
    }

    func testMeasuredOnStructEmitsError() throws {
        assertMacroExpansion(
            """
            @Measured
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
            macros: loggingMacros
        )
    }
}

// MARK: - OSLogged Tests

final class OSLoggedTests: XCTestCase {
    func testOSLoggedOnStruct() throws {
        assertMacroExpansion(
            """
            @OSLogged(subsystem: "com.app", category: "network")
            struct NetworkService {
            }
            """,
            expandedSource: """
            struct NetworkService {

                private static let logger = Logger(subsystem: "com.app", category: "network")
            }
            """,
            macros: loggingMacros
        )
    }

    func testOSLoggedOnClass() throws {
        assertMacroExpansion(
            """
            @OSLogged(subsystem: "com.app", category: "auth")
            class AuthManager {
            }
            """,
            expandedSource: """
            class AuthManager {

                private static let logger = Logger(subsystem: "com.app", category: "auth")
            }
            """,
            macros: loggingMacros
        )
    }

    func testOSLoggedOnEnumEmitsError() throws {
        assertMacroExpansion(
            """
            @OSLogged(subsystem: "com.app", category: "util")
            enum Util {
            }
            """,
            expandedSource: """
            enum Util {
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: MacroError.requiresStructOrClass.message, line: 1, column: 1)
            ],
            macros: loggingMacros
        )
    }
}

// MARK: - Crashlytic Tests

final class CrashlyticTests: XCTestCase {
    func testCrashlyticOnFunction() throws {
        assertMacroExpansion(
            """
            @Crashlytic
            func riskyOperation() throws {
            }
            """,
            expandedSource: """
            func riskyOperation() throws {
            }

            func safe_riskyOperation() {
                do {
                    try riskyOperation()
                } catch {
                    print("[Crashlytic] Non-fatal error in riskyOperation: \\(error)")
                }
            }
            """,
            macros: loggingMacros
        )
    }

    func testCrashlyticOnStructEmitsError() throws {
        assertMacroExpansion(
            """
            @Crashlytic
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
            macros: loggingMacros
        )
    }
}

// MARK: - Traced Tests

final class TracedTests: XCTestCase {
    func testTracedOnFunction() throws {
        assertMacroExpansion(
            """
            @Traced
            func loadData() async throws {
            }
            """,
            expandedSource: """
            func loadData() async throws {
            }

            func traced_loadData() async throws {
                let signpostID = OSSignpostID(log: .default)
                os_signpost(.begin, log: .default, name: "loadData", signpostID: signpostID)
                defer {
                    os_signpost(.end, log: .default, name: "loadData", signpostID: signpostID)
                }
                try await loadData()
            }
            """,
            macros: loggingMacros
        )
    }

    func testTracedOnStructEmitsError() throws {
        assertMacroExpansion(
            """
            @Traced
            struct Config {
            }
            """,
            expandedSource: """
            struct Config {
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: MacroError.requiresAsyncFunction.message, line: 1, column: 1)
            ],
            macros: loggingMacros
        )
    }
}

#endif
