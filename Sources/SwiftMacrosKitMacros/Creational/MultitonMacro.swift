// MultitonMacro.swift
// SwiftMacrosKit — Multiton Macro Implementation
// Category: [A] Creational Patterns
// Author: SwiftMacrosKit Contributors

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics

public struct MultitonMacro: MemberMacro {
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
            "private static var instances: [String: \(raw: className)] = [:]",
            "private static let instancesLock = NSLock()",
            """
            static func instance(for key: String) -> \(raw: className) {
                instancesLock.lock()
                defer { instancesLock.unlock() }
                if let existing = instances[key] {
                    return existing
                }
                let new = \(raw: className)()
                instances[key] = new
                return new
            }
            """,
        ]
    }
}
