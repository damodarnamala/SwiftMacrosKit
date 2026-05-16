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
                get {
                    _count
                }
                set {
                    let validate = {
                        $0 > 0
                    }
                    if validate(newValue) {
                        _count = newValue
                    }
                }
            }

            var _count: Int = 1
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

            var _count: Int = 1
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
                get {
                    _name
                }
                set {
                    if !newValue.isEmpty {
                        _name = newValue
                    }
                }
            }

            var _name: String = "default"
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
                get {
                    _items
                }
                set {
                    if !newValue.isEmpty {
                        _items = newValue
                    }
                }
            }

            var _items: [Int] = [1]
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
                get {
                    _percentage
                }
                set {
                    if newValue < 0 {
                        _percentage = 0
                    } else if newValue > 100 {
                        _percentage = 100
                    } else {
                        _percentage = newValue
                    }
                }
            }

            var _percentage: Int = 50
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

            var _percentage: Int = 50
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
                get {
                    _code
                }
                set {
                    let pattern = "^[0-9]+$"
                    if newValue.range(of: pattern, options: .regularExpression) != nil {
                        _code = newValue
                    }
                }
            }

            var _code: String = "123"
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

            var _code: String = "123"
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
                get {
                    _email
                }
                set {
                    let pattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\\\.[A-Za-z]{2,}"
                    let pred = NSPredicate(format: "SELF MATCHES %@", pattern)
                    if pred.evaluate(with: newValue) {
                        _email = newValue
                    }
                }
            }

            var _email: String = "user@example.com"
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
                get {
                    _contact
                }
                set {
                    let pattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\\\.[A-Za-z]{2,}"
                    let pred = NSPredicate(format: "SELF MATCHES %@", pattern)
                    if pred.evaluate(with: newValue) {
                        _contact = newValue
                    }
                }
            }

            var _contact: String = "test@test.org"
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
                get {
                    _link
                }
                set {
                    if URL(string: newValue) != nil {
                        _link = newValue
                    }
                }
            }

            var _link: String = "https://example.com"
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
                get {
                    _website
                }
                set {
                    if URL(string: newValue) != nil {
                        _website = newValue
                    }
                }
            }

            var _website: String = "https://swift.org"
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
                get {
                    _username
                }
                set {
                    if newValue.count >= 3 {
                        _username = newValue
                    }
                }
            }

            var _username: String = "abc"
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

            var _username: String = "abc"
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
                get {
                    _bio
                }
                set {
                    if newValue.count > 100 {
                        let endIndex = newValue.index(newValue.startIndex, offsetBy: 100)
                        _bio = String(newValue[newValue.startIndex ..< endIndex])
                    } else {
                        _bio = newValue
                    }
                }
            }

            var _bio: String = ""
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

            var _bio: String = ""
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
                get {
                    _value
                }
                set {
                    if newValue == nil {
                        preconditionFailure("\\(type(of: self)).value must not be nil")
                    }
                    _value = newValue
                }
            }

            var _value: String? = "hello"
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
                get {
                    _data
                }
                set {
                    if newValue == nil {
                        preconditionFailure("\\(type(of: self)).data must not be nil")
                    }
                    _data = newValue
                }
            }

            var _data: Int? = 42
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
                get {
                    _level
                }
                set {
                    precondition(newValue >= 1 && newValue <= 10,
                        "\\(type(of: self)).level must be in range \\(1)...\\(10), got \\(newValue)")
                    _level = newValue
                }
            }

            var _level: Int = 5
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

            var _level: Int = 5
            """,
            diagnostics: [
                DiagnosticSpec(message: MacroError.missingArguments.message, line: 1, column: 1)
            ],
            macros: validationMacros
        )
    }
}

#endif
