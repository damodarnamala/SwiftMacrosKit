// AutoInitMacro.swift
// SwiftMacrosKit — AutoInit Macro Implementation
// Category: [A] Creational Patterns
// Author: SwiftMacrosKit Contributors

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics

public struct AutoInitMacro: MemberMacro {
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

        var paramList = [String]()
        var assignList = [String]()

        for prop in properties {
            guard let name = prop.propertyName,
                  let type = prop.propertyTypeName else { continue }

            if prop.isOptional {
                paramList.append("\(name): \(type) = nil")
            } else if let defaultVal = prop.initialValue {
                paramList.append("\(name): \(type) = \(defaultVal.trimmedDescription)")
            } else {
                paramList.append("\(name): \(type)")
            }
            assignList.append("self.\(name) = \(name)")
        }

        let paramsStr = paramList.joined(separator: ", ")
        let assignsStr = assignList.joined(separator: "\n        ")

        let accessLevel = declaration.isClass ? "internal " : ""

        let initDecl: DeclSyntax = """
        \(raw: accessLevel)init(\(raw: paramsStr)) {
            \(raw: assignsStr)
        }
        """

        return [initDecl]
    }
}
