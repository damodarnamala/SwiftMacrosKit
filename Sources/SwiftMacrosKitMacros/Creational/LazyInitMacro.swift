// LazyInitMacro.swift
// SwiftMacrosKit — LazyInit Macro Implementation
// Category: [A] Creational Patterns
// Author: SwiftMacrosKit Contributors

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics

public struct LazyInitMacro: AccessorMacro, PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        guard let varDecl = declaration.as(VariableDeclSyntax.self),
              let name = varDecl.propertyName,
              let type = varDecl.propertyTypeName else {
            return []
        }

        let accessor: AccessorDeclSyntax = """
        get {
            if _\(raw: name) == nil {
                _\(raw: name) = _\(raw: name)Initializer()
            }
            return _\(raw: name)!
        }
        """

        return [accessor]
    }

    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let varDecl = declaration.as(VariableDeclSyntax.self),
              let name = varDecl.propertyName,
              let type = varDecl.propertyTypeName else {
            context.addDiagnostics(from: MacroDiagnosticError(error: .requiresProperty), node: node)
            return []
        }

        // Extract the initializer expression from macro argument
        let initExpr: String
        if let args = node.labeledArguments.first {
            initExpr = args.expression.trimmedDescription
        } else {
            initExpr = "\(type)()"
        }

        return [
            "private var _\(raw: name): \(raw: type)?",
            "private let _\(raw: name)Initializer: () -> \(raw: type) = { \(raw: initExpr) }",
        ]
    }
}
