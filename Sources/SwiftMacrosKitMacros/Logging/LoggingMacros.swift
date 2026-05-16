// LoggingMacros.swift
// SwiftMacrosKit — Logging & Observability Macro Implementations
// Category: [I] Logging & Observability
// Author: SwiftMacrosKit Contributors

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics

// MARK: - LoggedMacro

public struct LoggedMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let funcDecl = declaration.as(FunctionDeclSyntax.self) else {
            context.addDiagnostic(.requiresFunction, at: node)
            return []
        }

        let name = funcDecl.functionName
        let level = node.labeledArguments.first(where: { $0.label == "level" })?.expression.trimmedDescription ?? ".default"
        let params = funcDecl.signature.parameterClause.trimmedDescription
        let returnClause = funcDecl.signature.returnClause?.trimmedDescription ?? ""
        let effectSpecs = funcDecl.signature.effectSpecifiers?.trimmedDescription ?? ""

        let paramForward = funcDecl.signature.parameterClause.parameters.map { param in
            let label = param.secondName?.trimmedDescription ?? param.firstName.trimmedDescription
            return "\(param.firstName.trimmedDescription): \(label)"
        }.joined(separator: ", ")

        let hasReturn = funcDecl.returnTypeName != nil

        let callExpr: String
        if hasReturn {
            callExpr = """
                let result = \(funcDecl.isThrowing ? "try " : "")\(funcDecl.isAsync ? "await " : "")\(name)(\(paramForward))
                    os_log(\(level), "EXIT %{public}s -> %{public}s", \(name.debugDescription), "\\(result)")
                    return result
            """
        } else {
            callExpr = """
                \(funcDecl.isThrowing ? "try " : "")\(funcDecl.isAsync ? "await " : "")\(name)(\(paramForward))
                    os_log(\(level), "EXIT %{public}s", \(name.debugDescription))
            """
        }

        return ["""
        func logged_\(raw: name)\(raw: params) \(raw: effectSpecs) \(raw: returnClause) {
            os_log(\(raw: level), "ENTER %{public}s", \(literal: name))
            \(raw: callExpr)
        }
        """]
    }
}

// MARK: - TracedMacro

public struct TracedMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let funcDecl = declaration.as(FunctionDeclSyntax.self) else {
            context.addDiagnostic(.requiresAsyncFunction, at: node)
            return []
        }

        let name = funcDecl.functionName

        return ["""
        func traced_\(raw: name)() async throws {
            let signpostID = OSSignpostID(log: .default)
            os_signpost(.begin, log: .default, name: \(literal: name), signpostID: signpostID)
            defer { os_signpost(.end, log: .default, name: \(literal: name), signpostID: signpostID) }
            try await \(raw: name)()
        }
        """]
    }
}

// MARK: - MeasuredMacro

public struct MeasuredMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let funcDecl = declaration.as(FunctionDeclSyntax.self) else {
            context.addDiagnostic(.requiresFunction, at: node)
            return []
        }

        let name = funcDecl.functionName
        let returnType = funcDecl.returnTypeName
        let hasReturn = returnType != nil

        if hasReturn {
            return ["""
            func measured_\(raw: name)() -> \(raw: returnType!) {
                let start = CFAbsoluteTimeGetCurrent()
                let result = \(raw: name)()
                let elapsed = CFAbsoluteTimeGetCurrent() - start
                print("[Measured] \(raw: name) took \\(elapsed)s")
                return result
            }
            """]
        } else {
            return ["""
            func measured_\(raw: name)() {
                let start = CFAbsoluteTimeGetCurrent()
                \(raw: name)()
                let elapsed = CFAbsoluteTimeGetCurrent() - start
                print("[Measured] \(raw: name) took \\(elapsed)s")
            }
            """]
        }
    }
}

// MARK: - OSLoggedMacro

public struct OSLoggedMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard declaration.isStruct || declaration.isClass else {
            context.addDiagnostic(.requiresStructOrClass, at: node)
            return []
        }

        let args = node.labeledArguments
        let subsystem = args.first(where: { $0.label == "subsystem" })?.expression.trimmedDescription ?? "\"com.app\""
        let category = args.first(where: { $0.label == "category" })?.expression.trimmedDescription ?? "\"default\""

        return [
            "private static let logger = Logger(subsystem: \(raw: subsystem), category: \(raw: category))",
        ]
    }
}

// MARK: - CrashlyticMacro

public struct CrashlyticMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let funcDecl = declaration.as(FunctionDeclSyntax.self) else {
            context.addDiagnostic(.requiresFunction, at: node)
            return []
        }

        let name = funcDecl.functionName
        let params = funcDecl.signature.parameterClause.trimmedDescription

        let paramForward = funcDecl.signature.parameterClause.parameters.map { param in
            let label = param.secondName?.trimmedDescription ?? param.firstName.trimmedDescription
            return "\(param.firstName.trimmedDescription): \(label)"
        }.joined(separator: ", ")

        return ["""
        func safe_\(raw: name)\(raw: params) {
            do {
                try \(raw: name)(\(raw: paramForward))
            } catch {
                print("[Crashlytic] Non-fatal error in \(raw: name): \\(error)")
            }
        }
        """]
    }
}

// MARK: - AnalyticsMacro

public struct AnalyticsMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let funcDecl = declaration.as(FunctionDeclSyntax.self) else {
            context.addDiagnostic(.requiresFunction, at: node)
            return []
        }

        let name = funcDecl.functionName
        let eventName = node.labeledArguments.first(where: { $0.label == "event" })?.expression.trimmedDescription
            ?? node.stringArguments.first ?? name

        return ["""
        func tracked_\(raw: name)() {
            AnalyticsProvider.shared?.track(event: \(literal: eventName))
            \(raw: name)()
        }
        """]
    }
}
