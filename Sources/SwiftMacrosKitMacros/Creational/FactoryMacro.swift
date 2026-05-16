// FactoryMacro.swift
// SwiftMacrosKit — Factory Macro Implementation
// Category: [A] Creational Patterns
// Author: SwiftMacrosKit Contributors

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics

public struct FactoryMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let enumDecl = declaration.as(EnumDeclSyntax.self) else {
            context.addDiagnostics(from: MacroDiagnosticError(error: .requiresEnum), node: node)
            return []
        }

        let typeName = enumDecl.name.trimmedDescription
        let cases = enumDecl.caseElements

        guard !cases.isEmpty else {
            context.addDiagnostics(from: MacroDiagnosticError(error: .noEnumCases), node: node)
            return []
        }

        var methods = [DeclSyntax]()

        for caseElement in cases {
            let caseName = caseElement.name.trimmedDescription
            let methodName = "make\(caseName.prefix(1).uppercased())\(caseName.dropFirst())"

            if let paramClause = caseElement.parameterClause {
                let params = paramClause.parameters
                var paramList = [String]()
                var argList = [String]()

                for (index, param) in params.enumerated() {
                    let label = param.firstName?.trimmedDescription ?? "_\(index)"
                    let type = param.type.trimmedDescription
                    paramList.append("\(label): \(type)")
                    argList.append("\(label): \(label)")
                }

                let paramsStr = paramList.joined(separator: ", ")
                let argsStr = argList.joined(separator: ", ")

                methods.append(
                    "static func \(raw: methodName)(\(raw: paramsStr)) -> \(raw: typeName) { .\(raw: caseName)(\(raw: argsStr)) }"
                )
            } else {
                methods.append(
                    "static func \(raw: methodName)() -> \(raw: typeName) { .\(raw: caseName) }"
                )
            }
        }

        return methods
    }
}
