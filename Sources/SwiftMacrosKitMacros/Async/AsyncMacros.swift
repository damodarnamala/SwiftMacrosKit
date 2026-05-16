// AsyncMacros.swift
// SwiftMacrosKit — Async & Concurrency Macro Implementations
// Category: [C] Async & Concurrency
// Author: SwiftMacrosKit Contributors

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics

// MARK: - RetryMacro

public struct RetryMacro: PeerMacro {
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
        let args = node.labeledArguments
        let attempts = args.first(where: { $0.label == "attempts" })?.expression.trimmedDescription ?? "3"
        let delay = args.first(where: { $0.label == "delay" })?.expression.trimmedDescription ?? "1.0"

        let params = funcDecl.signature.parameterClause.trimmedDescription
        let returnClause = funcDecl.signature.returnClause?.trimmedDescription ?? ""
        let effectSpecifiers = funcDecl.signature.effectSpecifiers?.trimmedDescription ?? "async throws"

        let paramForward = funcDecl.signature.parameterClause.parameters.map { param in
            let label = param.secondName?.trimmedDescription ?? param.firstName.trimmedDescription
            return "\(param.firstName.trimmedDescription): \(label)"
        }.joined(separator: ", ")

        return ["""
        func _retrying_\(raw: name)\(raw: params) \(raw: effectSpecifiers) \(raw: returnClause) {
            var lastError: Error?
            for attempt in 1...\(raw: attempts) {
                do {
                    return try await \(raw: name)(\(raw: paramForward))
                } catch {
                    lastError = error
                    if attempt < \(raw: attempts) {
                        try await Task.sleep(nanoseconds: UInt64(\(raw: delay) * 1_000_000_000))
                    }
                }
            }
            throw lastError!
        }
        """]
    }
}

// MARK: - TimeoutMacro

public struct TimeoutMacro: PeerMacro {
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
        let args = node.labeledArguments
        let seconds = args.first(where: { $0.label == "seconds" })?.expression.trimmedDescription ?? "30"

        let returnType = funcDecl.returnTypeName ?? "Void"
        let params = funcDecl.signature.parameterClause.trimmedDescription

        return ["""
        func _withTimeout_\(raw: name)\(raw: params) async throws -> \(raw: returnType) {
            try await withThrowingTaskGroup(of: \(raw: returnType).self) { group in
                group.addTask {
                    try await self.\(raw: name)()
                }
                group.addTask {
                    try await Task.sleep(nanoseconds: UInt64(\(raw: seconds) * 1_000_000_000))
                    throw CancellationError()
                }
                let result = try await group.next()!
                group.cancelAll()
                return result
            }
        }
        """]
    }
}

// MARK: - DebounceMacro

public struct DebounceMacro: PeerMacro {
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
        let seconds = node.labeledArguments.first(where: { $0.label == "seconds" })?.expression.trimmedDescription ?? "0.3"

        return [
            "private var _debounce_\(raw: name)_task: Task<Void, Never>?",
            """
            func debounced_\(raw: name)() {
                _debounce_\(raw: name)_task?.cancel()
                _debounce_\(raw: name)_task = Task {
                    try? await Task.sleep(nanoseconds: UInt64(\(raw: seconds) * 1_000_000_000))
                    guard !Task.isCancelled else { return }
                    \(raw: name)()
                }
            }
            """,
        ]
    }
}

// MARK: - ThrottleMacro

public struct ThrottleMacro: PeerMacro {
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
        let seconds = node.labeledArguments.first(where: { $0.label == "seconds" })?.expression.trimmedDescription ?? "1.0"

        return [
            "private var _throttle_\(raw: name)_lastCall: Date?",
            """
            func throttled_\(raw: name)() {
                let now = Date()
                if let last = _throttle_\(raw: name)_lastCall,
                   now.timeIntervalSince(last) < \(raw: seconds) {
                    return
                }
                _throttle_\(raw: name)_lastCall = now
                \(raw: name)()
            }
            """,
        ]
    }
}

// MARK: - BackgroundActorMacro

public struct BackgroundActorMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard declaration.is(FunctionDeclSyntax.self) || declaration.is(ClassDeclSyntax.self) else {
            context.addDiagnostic(.requiresFunction, at: node)
            return []
        }

        return ["""
        @globalActor
        actor BackgroundActor {
            static let shared = BackgroundActor()
        }
        """]
    }
}

// MARK: - AsyncCachedMacro

public struct AsyncCachedMacro: PeerMacro {
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
        let returnType = funcDecl.returnTypeName ?? "Void"

        return [
            "private var _cache_\(raw: name): \(raw: returnType)?",
            """
            func cached_\(raw: name)() async throws -> \(raw: returnType) {
                if let cached = _cache_\(raw: name) {
                    return cached
                }
                let result = try await \(raw: name)()
                _cache_\(raw: name) = result
                return result
            }
            """,
            """
            func invalidate_\(raw: name)() {
                _cache_\(raw: name) = nil
            }
            """,
        ]
    }
}

// MARK: - RateLimitMacro

public struct RateLimitMacro: PeerMacro {
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
        let args = node.labeledArguments
        let calls = args.first(where: { $0.label == "calls" })?.expression.trimmedDescription ?? "10"
        let per = args.first(where: { $0.label == "per" })?.expression.trimmedDescription ?? "60"

        return [
            "private var _rateLimit_\(raw: name)_timestamps: [Date] = []",
            """
            func rateLimited_\(raw: name)() throws {
                let now = Date()
                _rateLimit_\(raw: name)_timestamps = _rateLimit_\(raw: name)_timestamps.filter {
                    now.timeIntervalSince($0) < \(raw: per)
                }
                guard _rateLimit_\(raw: name)_timestamps.count < \(raw: calls) else {
                    fatalError("Rate limit exceeded for \(raw: name)")
                }
                _rateLimit_\(raw: name)_timestamps.append(now)
                \(raw: name)()
            }
            """,
        ]
    }
}

// MARK: - ConcurrentMacro

public struct ConcurrentMacro: PeerMacro {
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
        let returnType = funcDecl.returnTypeName ?? "Void"

        return ["""
        func concurrent_\(raw: name)<T>(items: [T], transform: @Sendable @escaping (T) async throws -> \(raw: returnType)) async throws -> [\(raw: returnType)] {
            try await withThrowingTaskGroup(of: \(raw: returnType).self) { group in
                for item in items {
                    group.addTask {
                        try await transform(item)
                    }
                }
                var results: [\(raw: returnType)] = []
                for try await result in group {
                    results.append(result)
                }
                return results
            }
        }
        """]
    }
}

// MARK: - SerialMacro

public struct SerialMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard declaration.isClass || declaration.isActor else {
            context.addDiagnostic(.requiresActorOrClass, at: node)
            return []
        }

        return [
            "private let _serialQueue = DispatchQueue(label: \"serial.queue\")",
            """
            func enqueue(_ operation: @escaping () -> Void) {
                _serialQueue.async {
                    operation()
                }
            }
            """,
        ]
    }
}
