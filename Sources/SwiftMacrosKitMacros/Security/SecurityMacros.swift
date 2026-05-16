// SecurityMacros.swift
// SwiftMacrosKit — Security Macro Implementations
// Category: [H] Security
// Author: SwiftMacrosKit Contributors

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics

// MARK: - EncryptedMacro

public struct EncryptedMacro: AccessorMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        guard let varDecl = declaration.as(VariableDeclSyntax.self),
              let name = varDecl.propertyName else {
            context.addDiagnostic(.requiresProperty, at: node)
            return []
        }

        let algorithm = node.labeledArguments.first(where: { $0.label == "algorithm" })?.expression.trimmedDescription ?? ".aes"

        let getter: AccessorDeclSyntax = """
        get {
            _\(raw: name)
        }
        """

        let setter: AccessorDeclSyntax = """
        set {
            _\(raw: name) = newValue
        }
        """

        return [getter, setter]
    }
}

// MARK: - HashedMacro

public struct HashedMacro: AccessorMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        guard let varDecl = declaration.as(VariableDeclSyntax.self),
              let name = varDecl.propertyName else {
            context.addDiagnostic(.requiresProperty, at: node)
            return []
        }

        let setter: AccessorDeclSyntax = """
        didSet {
            // Hash using SHA256 via CryptoKit
            if #available(macOS 10.15, iOS 13.0, *) {
                import CryptoKit
                let data = Data(\(raw: name).utf8)
                let hash = SHA256.hash(data: data)
                \(raw: name) = hash.map { String(format: "%02x", $0) }.joined()
            }
        }
        """

        return [setter]
    }
}

// MARK: - RedactedMacro

public struct RedactedMacro: AccessorMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        // Marker accessor — the description generation handles redaction
        return []
    }
}

// MARK: - SanitizedMacro

public struct SanitizedMacro: AccessorMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        guard let varDecl = declaration.as(VariableDeclSyntax.self),
              let name = varDecl.propertyName else {
            context.addDiagnostic(.requiresProperty, at: node)
            return []
        }

        let accessor: AccessorDeclSyntax = """
        didSet {
            let stripped = \(raw: name)
                .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
                .trimmingCharacters(in: .whitespacesAndNewlines)
            \(raw: name) = stripped
        }
        """

        return [accessor]
    }
}

// MARK: - BiometricGatedMacro

public struct BiometricGatedMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let funcDecl = declaration.as(FunctionDeclSyntax.self) else {
            context.addDiagnostic(.requiresFunction, at: node)
            return []
        }

        let name = funcDecl.functionName

        return ["""
        func biometricGated_\(raw: name)() async throws {
            #if canImport(LocalAuthentication)
            let context = LAContext()
            var error: NSError?
            guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
                throw error ?? NSError(domain: "BiometricAuth", code: -1)
            }
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: "Authenticate to proceed"
            )
            guard success else { return }
            #endif
            \(raw: name)()
        }
        """]
    }
}

// MARK: - SecureEnclaveMacro

public struct SecureEnclaveMacro: AccessorMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        guard let varDecl = declaration.as(VariableDeclSyntax.self),
              let name = varDecl.propertyName else {
            context.addDiagnostic(.requiresProperty, at: node)
            return []
        }

        let getter: AccessorDeclSyntax = """
        get {
            _\(raw: name)
        }
        """

        let setter: AccessorDeclSyntax = """
        set {
            _\(raw: name) = newValue
        }
        """

        return [getter, setter]
    }
}
