// UtilityTests.swift
// SwiftMacrosKit — Utility & DX Macro Tests

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(SwiftMacrosKitMacros)
@testable import SwiftMacrosKitMacros

let utilityMacros: [String: Macro.Type] = [
    "EquatablePlus": EquatablePlusMacro.self,
    "ComparablePlus": ComparablePlusMacro.self,
    "Copyable": CopyableMacro.self,
    "StringConvertible": StringConvertibleMacro.self,
    "CaseIterablePlus": CaseIterablePlusMacro.self,
    "Defaultable": DefaultableMacro.self,
    "DecodablePlus": DecodablePlusMacro.self,
    "EncodablePlus": EncodablePlusMacro.self,
    "Flagged": FlaggedMacro.self,
    "DeprecatedPlus": DeprecatedPlusMacro.self,
]

// MARK: - EquatablePlus Tests

final class EquatablePlusTests: XCTestCase {
    func testEquatablePlusOnClass() throws {
        assertMacroExpansion(
            """
            @EquatablePlus
            class User {
                var name: String = ""
                var age: Int = 0
            }
            """,
            expandedSource: """
            class User {
                var name: String = ""
                var age: Int = 0

                static func == (lhs: User, rhs: User) -> Bool {
                    lhs.name == rhs.name && lhs.age == rhs.age
                }
            }
            """,
            macros: utilityMacros
        )
    }

    func testEquatablePlusOnStructEmitsError() throws {
        assertMacroExpansion(
            """
            @EquatablePlus
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
            macros: utilityMacros
        )
    }
}

// MARK: - Copyable Tests

final class CopyableTests: XCTestCase {
    func testCopyableOnStruct() throws {
        assertMacroExpansion(
            """
            @Copyable
            struct Config {
                var value: Int = 0
            }
            """,
            expandedSource: """
            struct Config {
                var value: Int = 0

                func copy(_ modifier: (inout Config) -> Void) -> Config {
                    var copy = self
                    modifier(&copy)
                    return copy
                }
            }
            """,
            macros: utilityMacros
        )
    }

    func testCopyableOnClassEmitsError() throws {
        assertMacroExpansion(
            """
            @Copyable
            class Config {
            }
            """,
            expandedSource: """
            class Config {
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: MacroError.requiresStruct.message, line: 1, column: 1)
            ],
            macros: utilityMacros
        )
    }
}

// MARK: - StringConvertible Tests

final class StringConvertibleTests: XCTestCase {
    func testStringConvertibleOnStruct() throws {
        assertMacroExpansion(
            """
            @StringConvertible
            struct User {
                var name: String = ""
                var age: Int = 0
            }
            """,
            expandedSource: """
            struct User {
                var name: String = ""
                var age: Int = 0

                var description: String {
                    "User(name: \\(name), age: \\(age))"
                }
            }
            """,
            macros: utilityMacros
        )
    }
}

// MARK: - CaseIterablePlus Tests

final class CaseIterablePlusTests: XCTestCase {
    func testCaseIterablePlusOnEnum() throws {
        assertMacroExpansion(
            """
            @CaseIterablePlus
            enum Direction {
                case north
                case south
                case east
                case west
            }
            """,
            expandedSource: """
            enum Direction {
                case north
                case south
                case east
                case west

                static var allCases: [Direction] {
                    [.north, .south, .east, .west]
                }
            }
            """,
            macros: utilityMacros
        )
    }

    func testCaseIterablePlusOnStructEmitsError() throws {
        assertMacroExpansion(
            """
            @CaseIterablePlus
            struct Config {
            }
            """,
            expandedSource: """
            struct Config {
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: MacroError.requiresEnum.message, line: 1, column: 1)
            ],
            macros: utilityMacros
        )
    }
}

// MARK: - DecodablePlus Tests

final class DecodablePlusTests: XCTestCase {
    func testDecodablePlusOnStruct() throws {
        assertMacroExpansion(
            """
            @DecodablePlus
            struct User {
                var name: String = ""
                var age: Int = 0
            }
            """,
            expandedSource: """
            struct User {
                var name: String = ""
                var age: Int = 0

                enum CodingKeys: String, CodingKey {
                    case name
                        case age
                }

                init(from decoder: Decoder) throws {
                    let container = try decoder.container(keyedBy: CodingKeys.self)
                    name = (try? container.decode(String.self, forKey: .name)) ?? ""
                        age = (try? container.decode(Int.self, forKey: .age)) ?? 0
                }
            }
            """,
            macros: utilityMacros
        )
    }

    func testDecodablePlusOnClassEmitsError() throws {
        assertMacroExpansion(
            """
            @DecodablePlus
            class Config {
            }
            """,
            expandedSource: """
            class Config {
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: MacroError.requiresStruct.message, line: 1, column: 1)
            ],
            macros: utilityMacros
        )
    }
}

// MARK: - Flagged Tests

final class FlaggedTests: XCTestCase {
    func testFlaggedOnFunction() throws {
        assertMacroExpansion(
            """
            @Flagged(key: "newUI")
            func showDashboard() {
            }
            """,
            expandedSource: """
            func showDashboard() {
            }

            func flagged_showDashboard() {
                let isEnabled = UserDefaults.standard.bool(forKey: "newUI")
                guard isEnabled else {
                    return
                }
                showDashboard()
            }
            """,
            macros: utilityMacros
        )
    }

    func testFlaggedOnStructEmitsError() throws {
        assertMacroExpansion(
            """
            @Flagged(key: "test")
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
            macros: utilityMacros
        )
    }
}

// MARK: - DeprecatedPlus Tests

final class DeprecatedPlusTests: XCTestCase {
    func testDeprecatedPlusOnFunction() throws {
        assertMacroExpansion(
            """
            @DeprecatedPlus(message: "Use newMethod")
            func oldMethod() {
            }
            """,
            expandedSource: """
            func oldMethod() {
            }

            @available(*, deprecated, message: "Use newMethod")
            func deprecated_oldMethod() {
                print("WARNING: oldMethod is deprecated. \\(nil ?? "")")
                oldMethod()
            }
            """,
            macros: utilityMacros
        )
    }
}

#endif
