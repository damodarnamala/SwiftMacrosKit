// SecurityMacros.swift
// SwiftMacrosKit — Security Macro Implementations
// Category: [H] Security
// Author: SwiftMacrosKit Contributors

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics

// MARK: - Shared Security peer helper

private func makeSecurityPeerStorage(for declaration: some DeclSyntaxProtocol) -> [DeclSyntax] {
    guard let varDecl = declaration.as(VariableDeclSyntax.self),
          let name = varDecl.propertyName,
          let type = varDecl.propertyTypeName else {
        return []
    }
    if let initialValue = varDecl.initialValue {
        return ["var _\(raw: name): \(raw: type) = \(initialValue)"]
    }
    return ["var _\(raw: name): \(raw: type)"]
}

// MARK: - EncryptedMacro

public struct EncryptedMacro: AccessorMacro, PeerMacro {
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

    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        makeSecurityPeerStorage(for: declaration)
    }
}

// MARK: - HashedMacro

public struct HashedMacro: AccessorMacro, PeerMacro {
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

        let getter: AccessorDeclSyntax = "get { _\(raw: name) }"
        let setter: AccessorDeclSyntax = """
        set {
            let data = Data(newValue.utf8)
            let hash = SHA256.hash(data: data)
            _\(raw: name) = hash.map { String(format: "%02x", $0) }.joined()
        }
        """

        return [getter, setter]
    }

    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        makeSecurityPeerStorage(for: declaration)
    }
}

// MARK: - RedactedMacro

public struct RedactedMacro: AccessorMacro, PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        guard let varDecl = declaration.as(VariableDeclSyntax.self),
              let name = varDecl.propertyName else {
            return []
        }

        let getter: AccessorDeclSyntax = "get { _\(raw: name) }"
        let setter: AccessorDeclSyntax = """
        set {
            _\(raw: name) = newValue
        }
        """
        return [getter, setter]
    }

    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        makeSecurityPeerStorage(for: declaration)
    }
}

// MARK: - SanitizedMacro

public struct SanitizedMacro: AccessorMacro, PeerMacro {
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

        let getter: AccessorDeclSyntax = "get { _\(raw: name) }"
        let setter: AccessorDeclSyntax = """
        set {
            _\(raw: name) = newValue
                .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
                .trimmingCharacters(in: .whitespacesAndNewlines)
        }
        """

        return [getter, setter]
    }

    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        makeSecurityPeerStorage(for: declaration)
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

public struct SecureEnclaveMacro: AccessorMacro, PeerMacro {
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

    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        makeSecurityPeerStorage(for: declaration)
    }
}
