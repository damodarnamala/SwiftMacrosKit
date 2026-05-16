// DefaultInitMacro.swift
// SwiftMacrosKit — DefaultInit Macro Implementation
// Category: [A] Creational Patterns
// Author: SwiftMacrosKit Contributors

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics

public struct DefaultInitMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard declaration.isStruct || declaration.isClass else {
            context.addDiagnostics(from: MacroDiagnosticError(error: .requiresStructOrClass), node: node)
            return []
        }

        let properties = declaration.storedProperties

        guard !properties.isEmpty else {
            context.addDiagnostics(from: MacroDiagnosticError(error: .noStoredProperties), node: node)
            return []
        }

        var assignList = [String]()

        for prop in properties {
            guard let name = prop.propertyName else { continue }

            if let defaultVal = prop.initialValue {
                assignList.append("self.\(name) = \(defaultVal.trimmedDescription)")
            } else if prop.isOptional {
                assignList.append("self.\(name) = nil")
            } else {
                context.addDiagnostics(
                    from: MacroDiagnosticError(error: .missingDefaultValue),
                    node: prop
                )
                return []
            }
        }

        let assignsStr = assignList.joined(separator: "\n        ")

        let initDecl: DeclSyntax = """
        init() {
            \(raw: assignsStr)
        }
        """

        return [initDecl]
    }
}
