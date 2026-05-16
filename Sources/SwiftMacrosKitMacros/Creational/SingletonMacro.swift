// SingletonMacro.swift
// SwiftMacrosKit — Singleton Macro Implementation
// Category: [A] Creational Patterns
// Author: SwiftMacrosKit Contributors

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics

public struct SingletonMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let classDecl = declaration.as(ClassDeclSyntax.self) else {
            context.addDiagnostics(from: MacroDiagnosticError(error: .requiresClass), node: node)
            return []
        }

        let className = classDecl.name.trimmedDescription

        return [
            "static let shared = \(raw: className)()",
            "private init() {}",
        ]
    }
}
