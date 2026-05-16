// PoolMacro.swift
// SwiftMacrosKit — Pool Macro Implementation
// Category: [A] Creational Patterns
// Author: SwiftMacrosKit Contributors

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics

public struct PoolMacro: MemberMacro {
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
            "private static var pool: [\(raw: className)] = []",
            "private static let poolLock = NSLock()",
            """
            static func acquire() -> \(raw: className) {
                poolLock.lock()
                defer { poolLock.unlock() }
                if let obj = pool.popLast() {
                    return obj
                }
                return \(raw: className)()
            }
            """,
            """
            static func release(_ obj: \(raw: className)) {
                poolLock.lock()
                defer { poolLock.unlock() }
                pool.append(obj)
            }
            """,
        ]
    }
}
