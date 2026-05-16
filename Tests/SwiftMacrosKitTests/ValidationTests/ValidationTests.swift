// ValidationTests.swift
// SwiftMacrosKit — Validation Macro Tests
// Category: [K] Validation
// Author: SwiftMacrosKit Contributors

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(SwiftMacrosKitMacros)
@testable import SwiftMacrosKitMacros

let validationMacros: [String: Macro.Type] = [
    "Validated": ValidatedMacro.self,
    "NonEmpty": NonEmptyMacro.self,
    "Clamped": ClampedMacro.self,
    "RegexValidated": RegexValidatedMacro.self,
    "Email": EmailMacro.self,
    "URLValidated": URLValidatedMacro.self,
    "MinLength": MinLengthMacro.self,
    "MaxLength": MaxLengthMacro.self,
    "NotNil": NotNilMacro.self,
    "Range": RangeMacro.self,
]

// MARK: - Validated Tests

final class ValidatedTests: XCTestCase {
    func testValidatedOnProperty() throws {
        assertMacroExpansion(
            """
            @Validated({ $0 > 0 }) var count: Int = 1
            """,
            expandedSource: """
            var count: Int = 1 {
                didSet {
                    let validate = {
                        $0 > 0
                    }
                    if !validate(count) {
                        count = oldValue
                    }
                }
            }
            """,
            macros: validationMacros
        )
    }

    func testValidatedOnFunctionEmitsError() throws {
        assertMacroExpansion(
            """
            @Validated({ $0 > 0 }) func doSomething() {
            }
            """,
            expandedSource: """
            func doSomething() {
            }
            """,
            macros: validationMacros
        )
    }

    func testValidatedMissingArgumentsEmitsError() throws {
        assertMacroExpansion(
            """
            @Validated var count: Int = 1
            """,
            expandedSource: """
            var count: Int = 1
            """,
            diagnostics: [
                DiagnosticSpec(message: MacroError.missingArguments.message, line: 1, column: 1)
            ],
            macros: validationMacros
        )
    }
}

// MARK: - NonEmpty Tests

final class NonEmptyTests: XCTestCase {
    func testNonEmptyOnStringProperty() throws {
        assertMacroExpansion(
            """
            @NonEmpty var name: String = "default"
            """,
            expandedSource: """
            var name: String = "default" {
                didSet {
                    if name.isEmpty {
                        name = oldValue
                    }
                }
            }
            """,
            macros: validationMacros
        )
    }

    func testNonEmptyOnFunctionEmitsError() throws {
        assertMacroExpansion(
            """
            @NonEmpty func doSomething() {
            }
            """,
            expandedSource: """
            func doSomething() {
            }
            """,
            macros: validationMacros
        )
    }

    func testNonEmptyOnArrayProperty() throws {
        assertMacroExpansion(
            """
            @NonEmpty var items: [Int] = [1]
            """,
            expandedSource: """
            var items: [Int] = [1] {
                didSet {
                    if items.isEmpty {
                        items = oldValue
                    }
                }
            }
            """,
            macros: validationMacros
        )
    }
}

// MARK: - Clamped Tests

final class ClampedTests: XCTestCase {
    func testClampedOnProperty() throws {
        assertMacroExpansion(
            """
            @Clamped(min: 0, max: 100) var percentage: Int = 50
            """,
            expandedSource: """
            var percentage: Int = 50 {
                didSet {
                    if percentage < 0 {
                        percentage = 0
                    }
                    if percentage > 100 {
                        percentage = 100
                    }
                }
            }
            """,
            macros: validationMacros
        )
    }

    func testClampedOnFunctionEmitsError() throws {
        assertMacroExpansion(
            """
            @Clamped(min: 0, max: 100) func doSomething() {
            }
            """,
            expandedSource: """
            func doSomething() {
            }
            """,
            macros: validationMacros
        )
    }

    func testClampedMissingArgumentsEmitsError() throws {
        assertMacroExpansion(
            """
            @Clamped var percentage: Int = 50
            """,
            expandedSource: """
            var percentage: Int = 50
            """,
            diagnostics: [
                DiagnosticSpec(message: MacroError.missingArguments.message, line: 1, column: 1)
            ],
            macros: validationMacros
        )
    }
}

// MARK: - RegexValidated Tests

final class RegexValidatedTests: XCTestCase {
    func testRegexValidatedOnProperty() throws {
        assertMacroExpansion(
            """
            @RegexValidated("^[0-9]+$") var code: String = "123"
            """,
            expandedSource: """
            var code: String = "123" {
                didSet {
                    let pattern = "^[0-9]+$"
                    if code.range(of: pattern, options: .regularExpression) == nil {
                        code = oldValue
                    }
                }
            }
            """,
            macros: validationMacros
        )
    }

    func testRegexValidatedOnFunctionEmitsError() throws {
        assertMacroExpansion(
            """
            @RegexValidated("^[0-9]+$") func doSomething() {
            }
            """,
            expandedSource: """
            func doSomething() {
            }
            """,
            macros: validationMacros
        )
    }

    func testRegexValidatedMissingArgumentsEmitsError() throws {
        assertMacroExpansion(
            """
            @RegexValidated var code: String = "123"
            """,
            expandedSource: """
            var code: String = "123"
            """,
            diagnostics: [
                DiagnosticSpec(message: MacroError.missingArguments.message, line: 1, column: 1)
            ],
            macros: validationMacros
        )
    }
}

// MARK: - Email Tests

final class EmailTests: XCTestCase {
    func testEmailOnProperty() throws {
        assertMacroExpansion(
            """
            @Email var email: String = "user@example.com"
            """,
            expandedSource: """
            var email: String = "user@example.com" {
                didSet {
                    let pattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\\\.[A-Za-z]{2,}"
                    let pred = NSPredicate(format: "SELF MATCHES %@", pattern)
                    if !pred.evaluate(with: email) {
                        email = oldValue
                    }
                }
            }
            """,
            macros: validationMacros
        )
    }

    func testEmailOnFunctionEmitsError() throws {
        assertMacroExpansion(
            """
            @Email func doSomething() {
            }
            """,
            expandedSource: """
            func doSomething() {
            }
            """,
            macros: validationMacros
        )
    }

    func testEmailOnAnotherProperty() throws {
        assertMacroExpansion(
            """
            @Email var contact: String = "test@test.org"
            """,
            expandedSource: """
            var contact: String = "test@test.org" {
                didSet {
                    let pattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\\\.[A-Za-z]{2,}"
                    let pred = NSPredicate(format: "SELF MATCHES %@", pattern)
                    if !pred.evaluate(with: contact) {
                        contact = oldValue
                    }
                }
            }
            """,
            macros: validationMacros
        )
    }
}

// MARK: - URLValidated Tests

final class URLValidatedTests: XCTestCase {
    func testURLValidatedOnProperty() throws {
        assertMacroExpansion(
            """
            @URLValidated var link: String = "https://example.com"
            """,
            expandedSource: """
            var link: String = "https://example.com" {
                didSet {
                    if URL(string: link) == nil {
                        link = oldValue
                    }
                }
            }
            """,
            macros: validationMacros
        )
    }

    func testURLValidatedOnFunctionEmitsError() throws {
        assertMacroExpansion(
            """
            @URLValidated func doSomething() {
            }
            """,
            expandedSource: """
            func doSomething() {
            }
            """,
            macros: validationMacros
        )
    }

    func testURLValidatedOnAnotherProperty() throws {
        assertMacroExpansion(
            """
            @URLValidated var website: String = "https://swift.org"
            """,
            expandedSource: """
            var website: String = "https://swift.org" {
                didSet {
                    if URL(string: website) == nil {
                        website = oldValue
                    }
                }
            }
            """,
            macros: validationMacros
        )
    }
}

// MARK: - MinLength Tests

final class MinLengthTests: XCTestCase {
    func testMinLengthOnProperty() throws {
        assertMacroExpansion(
            """
            @MinLength(3) var username: String = "abc"
            """,
            expandedSource: """
            var username: String = "abc" {
                didSet {
                    if username.count < 3 {
                        username = oldValue
                    }
                }
            }
            """,
            macros: validationMacros
        )
    }

    func testMinLengthOnFunctionEmitsError() throws {
        assertMacroExpansion(
            """
            @MinLength(3) func doSomething() {
            }
            """,
            expandedSource: """
            func doSomething() {
            }
            """,
            macros: validationMacros
        )
    }

    func testMinLengthMissingArgumentsEmitsError() throws {
        assertMacroExpansion(
            """
            @MinLength var username: String = "abc"
            """,
            expandedSource: """
            var username: String = "abc"
            """,
            diagnostics: [
                DiagnosticSpec(message: MacroError.missingArguments.message, line: 1, column: 1)
            ],
            macros: validationMacros
        )
    }
}

// MARK: - MaxLength Tests

final class MaxLengthTests: XCTestCase {
    func testMaxLengthOnProperty() throws {
        assertMacroExpansion(
            """
            @MaxLength(100) var bio: String = ""
            """,
            expandedSource: """
            var bio: String = "" {
                didSet {
                    if bio.count > 100 {
                        let endIndex = bio.index(bio.startIndex, offsetBy: 100)
                        bio = String(bio[bio.startIndex ..< endIndex])
                    }
                }
            }
            """,
            macros: validationMacros
        )
    }

    func testMaxLengthOnFunctionEmitsError() throws {
        assertMacroExpansion(
            """
            @MaxLength(100) func doSomething() {
            }
            """,
            expandedSource: """
            func doSomething() {
            }
            """,
            macros: validationMacros
        )
    }

    func testMaxLengthMissingArgumentsEmitsError() throws {
        assertMacroExpansion(
            """
            @MaxLength var bio: String = ""
            """,
            expandedSource: """
            var bio: String = ""
            """,
            diagnostics: [
                DiagnosticSpec(message: MacroError.missingArguments.message, line: 1, column: 1)
            ],
            macros: validationMacros
        )
    }
}

// MARK: - NotNil Tests

final class NotNilTests: XCTestCase {
    func testNotNilOnProperty() throws {
        assertMacroExpansion(
            """
            @NotNil var value: String? = "hello"
            """,
            expandedSource: """
            var value: String? = "hello" {
                didSet {
                    if value == nil {
                        preconditionFailure("\\(type(of: self)).value must not be nil")
                    }
                }
            }
            """,
            macros: validationMacros
        )
    }

    func testNotNilOnFunctionEmitsError() throws {
        assertMacroExpansion(
            """
            @NotNil func doSomething() {
            }
            """,
            expandedSource: """
            func doSomething() {
            }
            """,
            macros: validationMacros
        )
    }

    func testNotNilOnAnotherProperty() throws {
        assertMacroExpansion(
            """
            @NotNil var data: Int? = 42
            """,
            expandedSource: """
            var data: Int? = 42 {
                didSet {
                    if data == nil {
                        preconditionFailure("\\(type(of: self)).data must not be nil")
                    }
                }
            }
            """,
            macros: validationMacros
        )
    }
}

// MARK: - Range Tests

final class RangeTests: XCTestCase {
    func testRangeOnProperty() throws {
        assertMacroExpansion(
            """
            @Range(1, 10) var level: Int = 5
            """,
            expandedSource: """
            var level: Int = 5 {
                didSet {
                    precondition(level >= 1 && level <= 10,
                        "\\(type(of: self)).level must be in range \\(1)...\\(10), got \\(level)")
                }
            }
            """,
            macros: validationMacros
        )
    }

    func testRangeOnFunctionEmitsError() throws {
        assertMacroExpansion(
            """
            @Range(1, 10) func doSomething() {
            }
            """,
            expandedSource: """
            func doSomething() {
            }
            """,
            macros: validationMacros
        )
    }

    func testRangeMissingArgumentsEmitsError() throws {
        assertMacroExpansion(
            """
            @Range var level: Int = 5
            """,
            expandedSource: """
            var level: Int = 5
            """,
            diagnostics: [
                DiagnosticSpec(message: MacroError.missingArguments.message, line: 1, column: 1)
            ],
            macros: validationMacros
        )
    }
}

#endif
