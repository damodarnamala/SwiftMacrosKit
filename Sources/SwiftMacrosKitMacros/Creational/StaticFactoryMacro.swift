// StaticFactoryMacro.swift
// SwiftMacrosKit — StaticFactory Macro Implementation
// Category: [A] Creational Patterns
// Author: SwiftMacrosKit Contributors

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics

public struct StaticFactoryMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard declaration.isStruct else {
            context.addDiagnostics(from: MacroDiagnosticError(error: .requiresStruct), node: node)
            return []
        }

        guard let typeName = declaration.typeName else { return [] }

        let factoryName: String
        if let args = node.stringArguments.first {
            factoryName = args
        } else {
            context.addDiagnostics(from: MacroDiagnosticError(error: .missingArguments), node: node)
            return []
        }

        let properties = declaration.storedProperties

        var paramList = [String]()
        var argList = [String]()

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
            argList.append("\(name): \(name)")
        }

        let paramsStr = paramList.joined(separator: ", ")
        let argsStr = argList.joined(separator: ", ")

        let method: DeclSyntax = """
        static func \(raw: factoryName)(\(raw: paramsStr)) -> \(raw: typeName) {
            \(raw: typeName)(\(raw: argsStr))
        }
        """

        return [method]
    }
}
