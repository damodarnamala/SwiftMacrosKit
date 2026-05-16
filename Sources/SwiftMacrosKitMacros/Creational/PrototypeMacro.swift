// PrototypeMacro.swift
// SwiftMacrosKit — Prototype Macro Implementation
// Category: [A] Creational Patterns
// Author: SwiftMacrosKit Contributors

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics

public struct PrototypeMacro: MemberMacro {
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
        let properties = declaration.storedProperties

        var assignments = [String]()
        for prop in properties {
            guard let name = prop.propertyName else { continue }
            assignments.append("clone.\(name) = self.\(name)")
        }

        let assignmentsStr = assignments.joined(separator: "\n        ")

        let copyMethod: DeclSyntax = """
        func copy() -> \(raw: className) {
            let clone = \(raw: className)()
            \(raw: assignmentsStr)
            return clone
        }
        """

        return [copyMethod]
    }
}
