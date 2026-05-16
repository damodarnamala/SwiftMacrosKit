// FluentBuilderMacro.swift
// SwiftMacrosKit — FluentBuilder Macro Implementation
// Category: [A] Creational Patterns
// Author: SwiftMacrosKit Contributors

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics

public struct FluentBuilderMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard declaration.isStruct || declaration.isClass else {
            context.addDiagnostics(from: MacroDiagnosticError(error: .requiresStructOrClass), node: node)
            return []
        }

        guard let typeName = declaration.typeName else { return [] }
        let properties = declaration.storedProperties
        let isStruct = declaration.isStruct

        var methods = [DeclSyntax]()

        for prop in properties {
            guard let name = prop.propertyName,
                  let type = prop.propertyTypeName else { continue }

            let methodName = "with\(name.prefix(1).uppercased())\(name.dropFirst())"

            if isStruct {
                methods.append("""
                func \(raw: methodName)(_ value: \(raw: type)) -> \(raw: typeName) {
                    var copy = self
                    copy.\(raw: name) = value
                    return copy
                }
                """)
            } else {
                methods.append("""
                @discardableResult
                func \(raw: methodName)(_ value: \(raw: type)) -> Self {
                    self.\(raw: name) = value
                    return self
                }
                """)
            }
        }

        return methods
    }
}
