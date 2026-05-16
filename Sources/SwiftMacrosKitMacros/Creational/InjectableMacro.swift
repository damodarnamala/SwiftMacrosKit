// InjectableMacro.swift
// SwiftMacrosKit — Injectable Macro Implementation
// Category: [A] Creational Patterns
// Author: SwiftMacrosKit Contributors

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics

public struct InjectableMacro: MemberMacro {
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
        var typeList = [String]()

        for prop in properties {
            guard let name = prop.propertyName,
                  let type = prop.propertyTypeName else { continue }
            paramList.append("\(name): \(type)")
            assignList.append("self.\(name) = \(name)")
            typeList.append("\(type).self")
        }

        let paramsStr = paramList.joined(separator: ", ")
        let assignsStr = assignList.joined(separator: "\n        ")
        let typesStr = typeList.joined(separator: ", ")

        return [
            """
            init(\(raw: paramsStr)) {
                \(raw: assignsStr)
            }
            """,
            "static var dependencies: [Any.Type] { [\(raw: typesStr)] }",
        ]
    }
}
