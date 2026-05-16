// BuilderMacro.swift
// SwiftMacrosKit — Builder Macro Implementation
// Category: [A] Creational Patterns
// Author: SwiftMacrosKit Contributors

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics

public struct BuilderMacro: MemberMacro {
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

        guard !properties.isEmpty else {
            context.addDiagnostics(from: MacroDiagnosticError(error: .noStoredProperties), node: node)
            return []
        }

        var builderProps = [String]()
        var setMethods = [String]()
        var buildArgs = [String]()

        for prop in properties {
            guard let name = prop.propertyName,
                  let type = prop.propertyTypeName else { continue }

            let isOptional = prop.isOptional
            let storageType = isOptional ? type : "\(type)?"

            builderProps.append("private var \(name): \(storageType)")

            let setterName = "set\(name.prefix(1).uppercased())\(name.dropFirst())"
            setMethods.append("""
                @discardableResult
                func \(setterName)(_ value: \(type)) -> Builder {
                    self.\(name) = value
                    return self
                }
            """)

            if isOptional {
                buildArgs.append("\(name): \(name)")
            } else {
                buildArgs.append("\(name): \(name)!")
            }
        }

        let propsStr = builderProps.joined(separator: "\n        ")
        let methodsStr = setMethods.joined(separator: "\n        ")
        let argsStr = buildArgs.joined(separator: ", ")

        let builderClass: DeclSyntax = """
        class Builder {
            \(raw: propsStr)
            \(raw: methodsStr)
            func build() -> \(raw: typeName) {
                \(raw: typeName)(\(raw: argsStr))
            }
        }
        """

        return [builderClass]
    }
}
