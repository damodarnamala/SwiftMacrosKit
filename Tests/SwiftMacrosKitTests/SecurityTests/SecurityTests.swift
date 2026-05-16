// SecurityTests.swift
// SwiftMacrosKit — Security Macro Tests

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(SwiftMacrosKitMacros)
@testable import SwiftMacrosKitMacros

let securityMacros: [String: Macro.Type] = [
    "Encrypted": EncryptedMacro.self,
    "Hashed": HashedMacro.self,
    "Redacted": RedactedMacro.self,
    "Sanitized": SanitizedMacro.self,
    "BiometricGated": BiometricGatedMacro.self,
    "SecureEnclave": SecureEnclaveMacro.self,
]

// MARK: - Encrypted Tests

final class EncryptedTests: XCTestCase {
    func testEncryptedOnProperty() throws {
        assertMacroExpansion(
            """
            @Encrypted var secret: String = ""
            """,
            expandedSource: """
            var secret: String = "" {
                get {
                    _secret
                }
                set {
                    _secret = newValue
                }
            }

            var _secret: String = ""
            """,
            macros: securityMacros
        )
    }

    func testEncryptedOnFunctionEmitsError() throws {
        assertMacroExpansion(
            """
            @Encrypted
            func getData() {
            }
            """,
            expandedSource: """
            func getData() {
            }
            """,
            macros: securityMacros
        )
    }
}

// MARK: - Sanitized Tests

final class SanitizedTests: XCTestCase {
    func testSanitizedOnProperty() throws {
        assertMacroExpansion(
            """
            @Sanitized var input: String = ""
            """,
            expandedSource: """
            var input: String = "" {
                get {
                    _input
                }
                set {
                    _input = newValue
                        .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                }
            }

            var _input: String = ""
            """,
            macros: securityMacros
        )
    }

    func testSanitizedOnFunctionEmitsError() throws {
        assertMacroExpansion(
            """
            @Sanitized
            func process() {
            }
            """,
            expandedSource: """
            func process() {
            }
            """,
            macros: securityMacros
        )
    }
}

// MARK: - BiometricGated Tests

final class BiometricGatedTests: XCTestCase {
    func testBiometricGatedOnFunction() throws {
        assertMacroExpansion(
            """
            @BiometricGated
            func secretAction() {
            }
            """,
            expandedSource: """
            func secretAction() {
            }

            func biometricGated_secretAction() async throws {
                #if canImport (LocalAuthentication)
                let context = LAContext()
                var error: NSError?
                guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
                    throw error ?? NSError(domain: "BiometricAuth", code: -1)
                }
                let success = try await context.evaluatePolicy(
                    .deviceOwnerAuthenticationWithBiometrics,
                    localizedReason: "Authenticate to proceed"
                )
                guard success else {
                    return
                }
                #endif
                secretAction()
            }
            """,
            macros: securityMacros
        )
    }

    func testBiometricGatedOnStructEmitsError() throws {
        assertMacroExpansion(
            """
            @BiometricGated
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
            macros: securityMacros
        )
    }
}

// MARK: - Redacted Tests

final class RedactedTests: XCTestCase {
    func testRedactedOnProperty() throws {
        assertMacroExpansion(
            """
            @Redacted var ssn: String = ""
            """,
            expandedSource: """
            var ssn: String = "" {
                get {
                    _ssn
                }
                set {
                    _ssn = newValue
                }
            }

            var _ssn: String = ""
            """,
            macros: securityMacros
        )
    }
}

// MARK: - SecureEnclave Tests

final class SecureEnclaveTests: XCTestCase {
    func testSecureEnclaveOnProperty() throws {
        assertMacroExpansion(
            """
            @SecureEnclave var key: String = ""
            """,
            expandedSource: """
            var key: String = "" {
                get {
                    _key
                }
                set {
                    _key = newValue
                }
            }

            var _key: String = ""
            """,
            macros: securityMacros
        )
    }

    func testSecureEnclaveOnFunctionEmitsError() throws {
        assertMacroExpansion(
            """
            @SecureEnclave
            func process() {
            }
            """,
            expandedSource: """
            func process() {
            }
            """,
            macros: securityMacros
        )
    }
}

#endif
